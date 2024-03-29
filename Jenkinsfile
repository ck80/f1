#!/usr/bin/env groovy
node {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */
        echo 'I am logged in as $(whoami)'
        app = docker.build("ck80/f1tips")
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://registry.agoralogic.com:5000', 'docker-registry-credentials') {
            app.push("${env.BUILD_NUMBER}")
            /* app.push("latest") */
        }
    }

}
/*
    stage('Deploy'){
        echo 'ssh to web server and tell it to pull new image'
        sh 'ssh root@192.168.1.10 /mnt/user/rubydev/f1dev/dockerRun.sh'
    }
}
*/