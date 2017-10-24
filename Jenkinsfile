pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'SubmoduleOption', disableSubmodules: false, recursiveSubmodules: true, reference: '', trackingSubmodules: false]], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/muhkuh-sys/lxd_images.git']]])
            }
        }
        stage('Ubuntu 14.04 x64') {
            steps {
                sh './build_mbs-ubuntu-1404-x64.sh'
            }
        }
        stage('Ubuntu 14.04 x86') {
            steps {
                sh './build_mbs-ubuntu-1404-x86.sh'
            }
        }
        stage('Ubuntu 16.04 x64') {
            steps {
                sh './build_mbs-ubuntu-1604-x64.sh'
            }
        }
        stage('Ubuntu 16.04 x86') {
            steps {
                sh './build_mbs-ubuntu-1604-x86.sh'
            }
        }
        stage('Ubuntu 17.04 x64') {
            steps {
                sh './build_mbs-ubuntu-1704-x64.sh'
            }
        }
        stage('Ubuntu 17.04 x86') {
            steps {
                sh './build_mbs-ubuntu-1704-x86.sh'
            }
        }
        stage('Ubuntu 17.10 x64') {
            steps {
                sh './build_mbs-ubuntu-1710-x64.sh'
            }
        }
        stage('Ubuntu 17.10 x86') {
            steps {
                sh './build_mbs-ubuntu-1710-x86.sh'
            }
        }
    }
}
