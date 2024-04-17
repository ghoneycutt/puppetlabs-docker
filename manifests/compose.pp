# @summary install Docker Compose using the recommended curl command.
#
# @param ensure
#   Whether to install or remove Docker Compose
#   Valid values are absent present
#
# @param version
#   The version of Docker Compose to install.
#
class docker::compose (
  Enum[present,absent] $ensure  = present,
  Optional[String]     $version = $docker::params::compose_version,
) inherits docker::params {
  if $docker::manage_package {
    if $version and $ensure != 'absent' {
      $package_ensure = $version
    } else {
      $package_ensure = $ensure
    }

    case $facts['os']['family'] {
      'Debian': {
        package { 'docker-compose-plugin':
          ensure  => $package_ensure,
          require => $docker::use_upstream_package_source ? {
            true  => Apt::Source['docker'],
            false => undef,
          },
        }
      }
      'RedHat': {
        package { 'docker-compose-plugin':
          ensure  => $package_ensure,
          require => $docker::use_upstream_package_source ? {
            true  => Yumrepo['docker'],
            false => undef,
          },
        }
      }
      'Windows': {
        fail('Docker compose is installed with docker machine on Windows')
      }
      default: {
        fail('This module only works on Debian, RedHat or Windows.')
      }
    }
  }
}
