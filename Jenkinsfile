#!groovy

podTemplate(
  cloud: 'jenkins-slave',
  name: 'haskell-microservice',
  label: 'haskell-microservice',
  containers: [
    containerTemplate(
      name: 'stack-build',
      image: 'ivanbrennan/stack-build:0.1.5',
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

    stage('stack setup') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user --no-docker update
          stack --allow-different-user --no-docker setup
        """
      }
    }

    stage('stack hlint') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user --no-docker install hlint
          stack --allow-different-user --no-docker exec hlint -- src
          stack --allow-different-user --no-docker clean
        """
      }
    }

    stage('stack build') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user --no-docker build
        """
      }
    }

    stage('stack test') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user --no-docker test stackfoo
        """
      }
    }

    stage('image') {
      container('stack-build') {
        sh """
          #!/bin/bash
          INSTALL_ROOT=\$( stack --allow-different-user --no-docker \
                           path --local-install-root \
                           | sed "s:\$(pwd)/::g" )
          BINNAME=stackfoo
          IMAGENAME="docker.sumall.net/ibrennan/\${BINNAME}"
          VERSION=\$( grep -i "^version:" *.cabal | awk '{print \$2}' )

          /usr/bin/docker build -t \${IMAGENAME}-app:\${VERSION} \
            --build-arg=local_install_root=\${INSTALL_ROOT} . &&
          /usr/bin/docker tag \${IMAGENAME}-app:\${VERSION} \${IMAGENAME}-app:latest &&
          echo "Now we would push to the docker registry..."
          echo /usr/bin/docker push \${IMAGENAME}-app:\${VERSION} && \
          echo   /usr/bin/docker push \${IMAGENAME}-app:latest
        """
      }
    }
  }
}
