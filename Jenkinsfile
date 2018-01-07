#!groovy

podTemplate(
  cloud: 'jenkins-slave',
  name: 'haskell-microservice',
  label: 'haskell-microservice',
  containers: [
    containerTemplate(
      name: 'stack-build',
      image: 'ivanbrennan/stack-build:0.1.1',
      ttyEnabled: true,
      command: 'cat'
    ),
    containerTemplate(
      name: 'docker',
      image: 'docker:17.12',
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
    stage('clone') {
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

    stage('stack build') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --system-ghc build --no-docker \
            || echo "Build failed"
        """
      }
    }

    stage('stack exec') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --system-ghc exec --no-docker stackfoo \
            || echo "Exec failed"
        """
      }
    }

    stage('image') {
      container('docker') {
        sh """
          #!/bin/bash
          echo build docker image
        """
      }
    }
  }
}
