name             'cq'
maintainer       'Jakub Wadolowski'
maintainer_email 'jakub.wadolowski@cognifide.com'
license          'Apache-2.0'
description      'Installs and configures Adobe AEM (formerly CQ)'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.1'

depends          'java'
depends          'ulimit'
depends          'cq-unix-toolkit', '~> 1.3.0'

source_url       'https://github.com/jwadolowski/cookbook-cq'
issues_url       'https://github.com/jwadolowski/cookbook-cq/issues'

chef_version     '>= 13', '< 15'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'

supports         'redhat', '~> 6.0'
supports         'redhat', '~> 7.0'
