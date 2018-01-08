#!groovy

podTemplate(
  cloud: 'jenkins-slave',
  name: 'haskell-microservice',
  label: 'haskell-microservice',
  containers: [
    containerTemplate(
      name: 'stack-build',
      image: 'ivanbrennan/stack-build:0.1.3',
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

    stage('stack test') {
      container('stack-build') {
        sh """
          #!/bin/bash
          stack --system-ghc test --no-docker stackfoo \
            || echo "Test failed"
        """
      }
    }

    stage('image') {
      container('docker') {
        sh """
          #!/bin/bash
          INSTALL_ROOT=$(stack --system-ghc --no-docker path --local-install-root | sed "s:$(pwd)/::g")
          echo \$INSTALL_ROOT

          # get_deps \${INSTALL_ROOT}

          # IMAGENAME="docker.sumall.net/sumall/\${BINNAME}" && \
          # /usr/bin/docker build -t \${IMAGENAME}-app:\${VERSION} \
          #     --build-arg=local_install_root=\${INSTALL_ROOT} . && \
        """
      }
    }
  }
}
