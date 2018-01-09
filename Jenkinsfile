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

    stage('stack build') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user build --no-docker \
            || echo "Build failed"
        """
      }
    }

    stage('stack exec') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user exec --no-docker stackfoo \
            || echo "Exec failed"
        """
      }
    }

    stage('stack test') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --allow-different-user test --no-docker stackfoo \
            || echo "Test failed"
        """
      }
    }

    stage('image') {
      container('stack-build') {
        sh """
          #!/bin/bash
          INSTALL_ROOT=\$( stack \
                           --allow-different-user \
                           --no-docker \
                           path \
                           --local-install-root \
                           | sed "s:\$(pwd)/::g" )
          BINNAME=stackfoo
          IMAGENAME="docker.sumall.net/ibrennan/\${BINNAME}"
          VERSION=\$( grep -i "^version:" *.cabal | awk '{print \$2}' )

          /usr/bin/docker build -t \${IMAGENAME}-app:\${VERSION} \
              --build-arg=local_install_root=\${INSTALL_ROOT} . &&
          /usr/bin/docker tag \${IMAGENAME}-app:\${VERSION} \${IMAGENAME}-app:latest

          # get_deps \${INSTALL_ROOT}

          # IMAGENAME="docker.sumall.net/ibrennan/\${BINNAME}" && \
          # /usr/bin/docker build -t \${IMAGENAME}-app:\${VERSION} \
          #     --build-arg=local_install_root=\${INSTALL_ROOT} . && \
          # /usr/bin/docker tag \${IMAGENAME}-app:\${VERSION} \${IMAGENAME}-app:latest
        """
      }
    }
  }
}
