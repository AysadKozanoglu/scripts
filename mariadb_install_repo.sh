#!/usr/bin/env bash
# shellcheck disable=2016 disable=1091 disable=2059

# Notes:
#   2018-12-24 - Update to MaxScale Version 2.3

# This script will identify the OS distribution and version, make sure it's
# supported, and set up the appropriate MariaDB software repositories.

supported="The MariaDB Repository supports these Linux OSs, on x86-64 only:
    * RHEL/CentOS 6 & 7
    * Ubuntu 14.04 LTS (trusty), 16.04 LTS (xenial), & 18.04 LTS (bionic)
    * Debian 8 (jessie) & 9 (stretch)
    * SLES 12 & 15"

otherplatforms="See https://mariadb.com/kb/en/mariadb/mariadb-package-repository-setup-and-usage/#platform-support."

mariadb_server_version=mariadb-10.3
mariadb_maxscale_version=2.3
write_to_stdout=0
skip_key_import=0
skip_maxscale=0
skip_server=0
skip_tools=0

usage="Usage: curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- [OPTIONS]

    https://mariadb.com/kb/en/mariadb/mariadb-package-repository-setup-and-usage/

$supported

Options:
    --help                  Display this help and exit.

    --mariadb-server-version=<version>
                            Override the default MariaDB Server version.
                            By default, the script will use '$mariadb_server_version'.
    --mariadb-maxscale-version=<version>
                            Override the default MariaDB MaxScale version.
                            By default, the script will use '$mariadb_maxscale_version'.

    --os-type=<type>        Override detection of OS type. Acceptable values include
                            'debian', 'ubuntu', 'rhel', and 'sles'.
    --os-version=<version>  Override detection of OS version. Acceptable values depend
                            on the OS type you specify.

    --skip-key-import       Skip importing GPG signing keys.

    --skip-maxscale         Skip the 'MaxScale' repository.
    --skip-server           Skip the 'MariaDB Server' repository.
    --skip-tools            Skip the 'Tools' repository.

    --write-to-stdout       Write output to stdout instead of to the OS's
                            repository configuration. This will also skip
                            importing GPG keys and updating the package 
                            cache on platforms where that behavior exists.
"

# os_type = ubuntu, debian, rhel, sles
os_type=
# os_version as demanded by the OS (codename, major release, etc.)
os_version=

# These GPG key IDs are used to fetch keys from a keyserver on Ubuntu & Debian
key_ids=( 0x8167EE24 0xE3C94F49 0xcbcb082a1bb943db 0xF1656F24C74CD1D8 0x135659e928c12247 )
# These GPG URLs are used to fetch GPG keys on RHEL and SLES
key_urls=(
    https://downloads.mariadb.com/MariaDB/MariaDB-Server-GPG-KEY
    https://downloads.mariadb.com/MaxScale/MariaDB-MaxScale-GPG-KEY
    https://downloads.mariadb.com/Tools/MariaDB-Enterprise-GPG-KEY
)

msg(){
    type=$1 #${1^^}
    shift
    printf "[$type] %s\n" "$@" >&2
}

error(){
    msg error "$@"
    exit 1
}

while :; do
    case $1 in

        --mariadb-server-version)
            if [[ -n $2 ]] && [[ $2 != --* ]]; then
                mariadb_server_version=$2
                shift
            else
                error "The $1 option requires an argument."
            fi
            ;;
        --mariadb-server-version=?*)
	    mariadb_server_version=${1#*=}
	    ;;
        --mariadb-server-version=)
	    error "The $1 option requires an argument."
	    ;;

        --mariadb-maxscale-version)
            if [[ -n $2 ]] && [[ $2 != --* ]]; then
                mariadb_maxscale_version=$2
                shift
            else
                error "The $1 option requires an argument."
            fi
            ;;
        --mariadb-maxscale-version=?*)
	    mariadb_maxscale_version=${1#*=}
	    ;;
        --mariadb-maxscale-version=)
	    error "The $1 option requires an argument."
	    ;;

        --write-to-stdout)
            write_to_stdout=1
            ;;

        --skip-key-import)
            skip_key_import=1
            ;;
        --skip-maxscale)
            skip_maxscale=1
            ;;
        --skip-server)
            skip_server=1
            ;;
        --skip-tools)
            skip_tools=1
            ;;

        --os-type)
            if [[ -n $2 ]] && [[ $2 != --* ]]; then
                os_type=$2
                shift
            else
                error "The $1 option requires an argument."
            fi
            ;;
        --os-type=?*)
	    os_type=${1#*=}
	    ;;
        --os-type=)
	    error "The $1 option requires an argument."
	    ;;

        --os-version)
            if [[ -n $2 ]] && [[ $2 != --* ]]; then
                os_version=$2
                shift
            else
                error "The $1 option requires an argument."
            fi
            ;;
        --os-version=?*)
	    os_version=${1#*=}
	    ;;
        --os-version=)
	    error "The $1 option requires an argument."
	    ;;

	--help)
	    printf "%s" "$usage"
	    exit
            ;;

        -?*)
            msg warning "Unknown option (ignored): $1\n"
            ;;
        *)
            break
    esac
    shift
done

open_outfile(){
    unset outfile
    if (( write_to_stdout ))
    then
        exec 4>&1
    else
        case $1 in
            ubuntu|debian) outfile=/etc/apt/sources.list.d/mariadb.list ;;
            rhel) outfile=/etc/yum.repos.d/mariadb.repo ;;
            sles) outfile=/etc/zypp/repos.d/mariadb.repo ;;
            *) error "Sorry, your OS is not supported." "$supported"
        esac
        if [[ -e $outfile ]]
        then
	    local suffix=0
	    while [[ -e $outfile.old_$((++suffix)) ]]; do :; done
            msg warning "Found existing file at $outfile. Moving to $outfile.old_$suffix."
	    if ! mv "$outfile" "$outfile.old_$suffix"
            then
                error "Could not move existing '$outfile'. Aborting."\
                      "Use the --write-to-stdout option to see its effect without becoming root."
            fi
        fi
        if ! exec 4>"$outfile"
        then
            error "Could not open file $outfile for writing. Aborting."\
                  "Use the --write-to-stdout option to see its effect without becoming root."
        fi
    fi
}

identify_os(){
    arch=$(uname -m)
    # Check for macOS
    if [[ $(uname -s) == Darwin ]]
    then
        printf '%s\n' \
            'To install MariaDB Server from a repository on macOS, please use Homebrew:'\
            '    https://mariadb.com/kb/en/mariadb/installing-mariadb-on-macos-using-homebrew/'\
            'Or use the native PKG installer:'\
            '    https://mariadb.com/kb/en/mariadb/installing-mariadb-server-pkg-packages-on-macos/'
        exit
    # Check for RHEL/CentOS, Fedora, etc.
    elif command -v rpm >/dev/null && [[ -e /etc/redhat-release ]]
    then
        os_type=rhel
        el_version=$(rpm -qa '(oraclelinux|sl|redhat|centos|fedora)-release(|-server)' --queryformat '%{VERSION}')
        case $el_version in
            5*) os_version=5 ; error "RHEL/CentOS 5 is no longer supported." "$supported" ;;
            6*) os_version=6 ;;
            7*) os_version=7 ;;
             *) error "Detected RHEL or compatible but version ($el_version) is not supported." "$supported"  "$otherplatforms" ;;
         esac
         if [[ $arch == aarch64 ]] && [[ $os_version != 7 ]]; then error "Only RHEL/CentOS 7 are supported for ARM64. Detected version: '$os_version'"; fi
    elif [[ -e /etc/os-release ]]
    then
        . /etc/os-release
        # Is it Debian?
        case $ID in
            debian)
                os_type=debian
                debian_version=$(< /etc/debian_version)
                case $debian_version in
                    8*) os_version=jessie ;;
                    9*) os_version=stretch ;;
                     *) error "Detected Debian but version ($debian_version) is not supported." "$supported"  "$otherplatforms" ;;
                esac
                if [[ $arch == aarch64 ]]; then error "Debian is not currently supported for ARM64"; fi
                ;;
            ubuntu)
                os_type=ubuntu
                . /etc/lsb-release
                os_version=$DISTRIB_CODENAME
                case $os_version in
                    precise ) error 'Ubuntu version 12.04 LTS has reached End of Life and is no longer supported.' ;;
                    trusty ) ;;
                    xenial ) ;;
                    bionic ) ;;
                    *) error "Detected Ubuntu but version ($os_version) is not supported." "Only Ubuntu LTS releases are supported."  "$otherplatforms" ;;
                esac
                if [[ $arch == aarch64 ]]
                then
                    case $os_version in
                        xenial ) ;;
                        bionic ) ;;
                        *) error "Only Ubuntu 16/xenial & 18/bionic are supported for ARM64. Detected version: '$os_version'" ;;
                    esac
                fi
                ;;
            sles)
                os_type=sles
                os_version=${VERSION_ID%%.*}
                case $os_version in
                    # 11) ;; # not currently supported
                    12|15) ;;
                    *) error "Detected SLES but version ($os_version) is not supported."  "$otherplatforms" ;;
                esac
                if [[ $arch == aarch64 ]]; then error "SLES is not currently supported for ARM64"; fi
                ;;
        esac
    fi
    if ! [[ $os_type ]] || ! [[ $os_version ]]
    then
        error "Could not identify OS type or version." "$supported"
    fi
}

remove_mdbe_repo(){
    case $os_type in
        debian|ubuntu)
            # First, remove the MariaDB Enterprise Repository config package, if it's installed
            if dpkg -l mariadb-enterprise-repository &>/dev/null
            then
                msg info 'Removing mariadb-enterprise-repository package...'
                dpkg -P mariadb-enterprise-repository
            fi
            ;;
        rhel|sles)
            # First, remove the MariaDB Enterprise Repository config package, if it's installed
            if rpm -qs mariadb-enterprise-repository &>/dev/null
            then
                msg info 'Removing mariadb-enterprise-repository package...'
                rpm -e mariadb-enterprise-repository
            fi
            ;;
    esac
}

# The directory structure of the MariaDB Server repo is such that the directories for each
# version have "mariadb-" prepended to the version number (i.e. mariadb-10.1 instead of 10.1)
if [[ $mariadb_server_version != mariadb-* ]]
then
    msg warning "Adjusting given --mariadb-server-version ('$mariadb_server_version') to have the correct prefix ('mariadb-$mariadb_server_version')"
    mariadb_server_version=mariadb-$mariadb_server_version
fi

# If we're writing the repository info to stdout, let's not try to import the signing keys.
((write_to_stdout)) && skip_key_import=1

arch=$(uname -m)
case $arch in
    x86_64) ;;
    aarch64) skip_maxscale=1; skip_tools=1;;
    *) error "The MariaDB Repository only supports x86_64 and aarch64 (detected $arch)." "$supported" "$otherplatforms" ;;
esac

if [[ $os_type ]] && [[ $os_version ]]
then
    # Both were given on the command line, so we'll just try using those.
    msg info "Skipping OS detection and using OS type '$os_type' and version '$os_version' given on the command line."
elif [[ $os_type ]] || [[ $os_version ]]
then
error "The MariaDB Repository only support RHEL/CentOS 7 for ARM64 platforms (detected version $os_version)"    error 'If you give either --os-type or --os-version, you must give both.'
else
    identify_os
fi



rhel_repo_server='[mariadb-main]
name = MariaDB Server
baseurl = https://downloads.mariadb.com/MariaDB/%s/yum/rhel/$releasever/$basearch
gpgkey = file:///etc/pki/rpm-gpg/MariaDB-Server-GPG-KEY
gpgcheck = 1
enabled = 1'
rhel_repo_maxscale='[mariadb-maxscale]
# To use the latest stable release of MaxScale, use "latest" as the version
# To use the latest beta (or stable if no current beta) release of MaxScale, use "beta" as the version
name = MariaDB MaxScale
baseurl = https://downloads.mariadb.com/MaxScale/%s/centos/$releasever/$basearch
gpgkey = file:///etc/pki/rpm-gpg/MariaDB-MaxScale-GPG-KEY
gpgcheck = 1
enabled = 1'
rhel_repo_tools='[mariadb-tools]
name = MariaDB Tools
baseurl = https://downloads.mariadb.com/Tools/rhel/$releasever/$basearch
gpgkey = file:///etc/pki/rpm-gpg/MariaDB-Enterprise-GPG-KEY
gpgcheck = 1
enabled = 1'

deb_repo_server='# MariaDB Server
# To use a different major version of the server, or to pin to a specific minor version, change URI below.
deb http://downloads.mariadb.com/MariaDB/%s/repo/%s %s main'
deb_repo_maxscale='# MariaDB MaxScale
# To use the latest stable release of MaxScale, use "latest" as the version
# To use the latest beta (or stable if no current beta) release of MaxScale, use "beta" as the version
deb http://downloads.mariadb.com/MaxScale/%s/%s %s main'
deb_repo_tools='# MariaDB Tools
deb http://downloads.mariadb.com/Tools/%s %s main'

sles_repo_server='[mariadb-server]
name = MariaDB Server
baseurl = https://downloads.mariadb.com/MariaDB/%s/yum/sles/%s/$basearch
gpgkey = file:///etc/pki/rpm-gpg/MariaDB-Server-GPG-KEY
gpgcheck = 1
type=rpm-md
enabled = 1
priority=10'
sles_repo_maxscale='[mariadb-maxscale]
# To use the latest stable release of MaxScale, use "latest" as the version
# To use the latest beta (or stable if no current beta) release of MaxScale, use "beta" as the version
name = MariaDB MaxScale
baseurl = https://downloads.mariadb.com/MaxScale/%s/sles/%s/$basearch
gpgkey = file:///etc/pki/rpm-gpg/MariaDB-MaxScale-GPG-KEY
enabled = 1
gpgcheck = 1
type=rpm-md
priority=10'
sles_repo_tools='[mariadb-tools]
name = MariaDB Tools
baseurl = https://downloads.mariadb.com/Tools/sles/%s/$basearch
gpgkey = file:///etc/pki/rpm-gpg/MariaDB-Enterprise-GPG-KEY
enabled = 1
gpgcheck = 1
type=rpm-md
priority=10'

open_outfile "$os_type"

# If we're not writing to stdout, try to remove the mariadb-enterprise-repository package
((write_to_stdout)) || remove_mdbe_repo

case $os_type in
    ubuntu|debian)
        # If we are not writing to stdout, create an apt preferences file to give our 
        # packages the highest possible priority
        if ((write_to_stdout))
        then
            msg info 'If run without --write-to-stdout, this script will create /etc/apt/preferences.d/mariadb-enterprise.pref to give packages from MariaDB repositories highest priority, in order to avoid conflicts with packages from OS and other repositories.'
        else
            printf '%s\n' \
            'Package: *'\
            'Pin: origin downloads.mariadb.com'\
            'Pin-Priority: 1000'\
            > /etc/apt/preferences.d/mariadb-enterprise.pref
        fi
        { 
            ((skip_server)) || printf "$deb_repo_server\n\n" "$mariadb_server_version" "$os_type" "$os_version"
            ((skip_maxscale)) || printf "$deb_repo_maxscale\n\n" "$mariadb_maxscale_version" "$os_type" "$os_version"
            ((skip_tools)) || printf "$deb_repo_tools\n" "$os_type" "$os_version"
        } >&4
        ((write_to_stdout)) || msg info "Repository file successfully written to $outfile"
        if ! ((skip_key_import))
        then
            msg info 'Adding trusted package signing keys...' 
            if apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${key_ids[@]}" &&
               apt-get update
            then
                msg info 'Succeessfully added trusted package signing keys.' 
            else
                msg error 'Failed to add trusted package signing keys.'
            fi

        elif ((write_to_stdout))
        then
            msg info 'If run without --skip-key-import/--write-to-stdout, this script will import package signing keys used by MariaDB.'
        fi
        ;;
    rhel)
        {
            ((skip_server)) || printf "$rhel_repo_server\n\n" "$mariadb_server_version"
            ((skip_maxscale)) || printf "$rhel_repo_maxscale\n\n" "$mariadb_maxscale_version"
            ((skip_tools)) || printf "$rhel_repo_tools\n"
        } >&4
        ((write_to_stdout)) || msg info "Repository file successfully written to $outfile."
        if ! ((skip_key_import))
        then
            msg info 'Adding trusted package signing keys...'
            if rpm --import "${key_urls[@]}"
            then
                msg info 'Succeessfully added trusted package signing keys.'
            else
                msg error 'Failed to add trusted package signing keys.'
            fi
        fi
        ;;
    sles)
        {
            ((skip_server)) || printf "$sles_repo_server\n\n" "$mariadb_server_version" "$os_version"
            ((skip_maxscale)) || printf "$sles_repo_maxscale\n\n" "$mariadb_maxscale_version" "$os_version"
            ((skip_tools)) || printf "$sles_repo_tools\n" "$os_version"
        } >&4
        ((write_to_stdout)) || msg info "Repository file successfully written to $outfile."
        if ! ((skip_key_import))
        then
            if [[ $os_version = 11 ]]
            then
                # RPM in SLES 11 doesn't support HTTPS, so munge the URLs to use standard HTTP
                rpm --import "${key_urls[@]/#https/http}"
            else
                msg info 'Adding trusted package signing keys...'
                if rpm --import "${key_urls[@]}"
                then
                    msg info 'Succeessfully added trusted package signing keys.'
                else
                    msg error 'Failed to add trusted package signing keys.'
                fi
            fi
        fi
        ;;
    *)
        error "Sorry, your OS is not supported." "$supported"
        ;;
esac
