#!groovy

podTemplate(
  cloud: 'jenkins-slave',
  name: 'haskell-microservice',
  label: 'haskell-microservice',
  containers: [
    containerTemplate(
      name: 'stack-build',
      image: 'docker.sumall.net/ibrennan/stack-build:0.2.2',
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
          branch: 'master',
          changelog: false,
          credentialsId: 'jenkins_ssh_key',
          poll: false,
          url: 'git@github.com:ivanbrennan/stackfoo.git'
        )
      }
    }

    stage('connection test') {
      container('stack-build') {
        sh """
          #!/bin/bash
          ls -l
          echo Success
        """
      }
    }
  }
}
