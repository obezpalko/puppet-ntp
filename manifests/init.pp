# vim syntax=puppet ts=4 sw=4 tabexpand
class ntp ( $ntp_daemon = 'ntp', $ntp_servers = '') {

    case $operatingsystem {

        ubuntu, debian: {
            case $ntp_daemon {
                ntp: {
                    package { 'ntp':
                        ensure          => present,
                        install_options => ['--no-install-recommends'],
                    }
                    file { '/etc/ntp.conf':
                        content => template('ntp/etc_ntp_ubuntu.erb'),
                        ensure  => present,
                        owner   => root,
                        group   => root,
                        mode    => '0644',
                        notify  => Exec['restart-ntp']
                    }
                    file { '/etc/default/ntp':
                        content => template('ntp/etc_default_ntp.erb'),
                        ensure  => present,
                        owner   => root,
                        group   => root,
                        mode    => '0644',
                        notify  => Exec['restart-ntp']
                    }
                    service { 'ntp':
                        ensure     => running,
                        hasstatus  => true,
                        hasrestart => true,
                        require    => Package['ntp']
                    }
                    exec { 'restart-ntp':
                        command     => "/usr/sbin/service ntp restart",
                        refreshonly => true,
                    }
                }
                openntpd: {
                    service {'apparmor':
                        ensure     => running,
                        hasrestart => true,
                    }
                    exec {'restart apparmor':
                        command     => '/usr/sbin/service apparmor restart',
                        refreshonly => true,
                        require     => Service['apparmor'],
                    }
                    package { 'ntp':
                        ensure => purged,
                        notify => Exec['restart apparmor'],
                    }
                    package { 'openntpd':
                        ensure  => latest,
                        require => Package['ntp'],
                    }
                    exec {'restart openntpd':
                        command     => '/usr/sbin/service openntpd restart',
                        refreshonly => true,
                        require     => Service['openntpd'],
                    }
                    service { 'openntpd':
                        ensure     => running,
                        hasstatus  => true,
                        hasrestart => true,
                        require    => Package['openntpd'],
                    }
                    file { '/etc/openntpd/ntpd.conf':
                        content => template('ntp/etc_openntpd_ntpd.erb'),
                        ensure  => present,
                        owner   => 'root',
                        group   => 'root',
                        mode    => '0644',
                        notify  => Exec['restart openntpd'],
                    }
                }

                default: {
                    warning {"Ntp Daemon ${ntp_daemon} is not supported":}
                }
            }
        }

        centos, redhat: {
            package { 'ntp':
                ensure => present,
            }
            file { '/etc/ntp.conf':
                content => template('ntp/etc_ntp_centos.erb'),
                ensure  => present,
                owner   => root,
                group   => root,
                mode    => '0644',
                notify  => Exec['restart-ntp']
            }
            file { '/etc/sysconfig/ntpd':
                content => template('ntp/etc_sysconfig_ntpd.erb'),
                ensure  => present,
                owner   => root,
                group   => root,
                mode    => '0644',
                notify  => Exec['restart-ntp']
            }
            service { 'ntpd':
                ensure     => running,
                hasstatus  => true,
                hasrestart => true,
                require    => Package['ntp']
            }
            exec { 'restart-ntp':
                command     => "/usr/sbin/service ntpd restart",
                refreshonly => true,
            }
        }

        default: {
            warning {"${operatingsystem} is not supported":}
        }
    }
}
