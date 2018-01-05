#!groovy

podTemplate(
  cloud: 'jenkins-slave',
  name: 'haskell-microservice',
  label: 'haskell-microservice',
  containers: [
    containerTemplate(
      name: 'stack-build',
      image: 'ivanbrennan/stack-docker-build:0.0.1',
      alwaysPullImage: true,
      ttyEnabled: true,
      command: 'cat'
    )
  ],
  volumes: [
    hostPathVolume(
      hostPath: '/var/run/docker.sock',
      mountPath: '/var/run/docker.sock'
    )
  ]
) {
  node('haskell-microservice') {
    stage('clone repo') {
      container('stack-build') {
        git(
          branch: 'jenkins',
          changelog: false,
          credentialsId: 'jenkins_ssh_key',
          poll: false,
          url: 'git@github.com:ivanbrennan/stackfoo.git'
        )
      }
    }

    stage('chown') {
      container('stack-build') {
        sh """
          #!/bin/bash
          chown -hR root .
        """
      }
    }

    stage('stack') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack build --no-docker \
            || echo "Build failed"
        """
      }
    }

    stage('inspect') {
      container('stack-build') {
        sh """
          #!/bin/bash
          whoami

          id -u

          ls -l .

          ls -ld ~
        """
      }
    }
  }
}
