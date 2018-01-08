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
          stack --system-ghc exec --no-docker stackfoo \
            || echo "Exec failed"
          stack --system-ghc test --no-docker stackfoo \
            || echo "Test failed"

          stack --system-ghc --no-docker path --local-install-root \
            | sed "s:\$(pwd)/::g" \
            > local_install_root
        """
      }
    }

    stage('image') {
      container('docker') {
        sh """
          #!/bin/bash
          INSTALL_ROOT=\$( cat local_install_root )
          BINNAME=stackfoo
          IMAGENAME="docker.sumall.net/ibrennan/\${BINNAME}"
          VERSION=\$( grep -i "^version:" *.cabal | awk '{print \$2}' )

          /usr/local/bin/docker build -t \${IMAGENAME}-app:\${VERSION} \
              --build-arg=local_install_root=\${INSTALL_ROOT} . &&
          /usr/local/bin/docker tag \${IMAGENAME}-app:\${VERSION} \${IMAGENAME}-app:latest

          # get_deps \${INSTALL_ROOT}

          # IMAGENAME="docker.sumall.net/ibrennan/\${BINNAME}" && \
          # /usr/local/bin/docker build -t \${IMAGENAME}-app:\${VERSION} \
          #     --build-arg=local_install_root=\${INSTALL_ROOT} . && \
          # /usr/local/bin/docker tag \${IMAGENAME}-app:\${VERSION} \${IMAGENAME}-app:latest
        """
      }
    }
  }
}
