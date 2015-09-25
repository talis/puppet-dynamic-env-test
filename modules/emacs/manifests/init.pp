class emacs {
  package { "emacs" : ensure => present }
  package { "puppet-el" : ensure => present }
}