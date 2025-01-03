pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = "f3e531c6-e05f-42a9-a526-fef5df18db89"
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    date
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }


        stage('Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            #test -f build/index.html
                            npm test
                        '''
                    }
                }
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
       stage('Deploy Staging') {

            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }           

            steps {
                sh '''
                npm install netlify-cli node-jq
                node_modules/.bin/netlify --version
                node_modules/.bin/netlify status
                echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json)
                npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    junit 'jest-results/junit.xml'
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

        stage('Deploy Prod') {
            environment {
                CI_ENVIRONMENT_URL = 'https://superb-tulumba-17e926.netlify.app'
            }
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                    reuseNode true
                }
            }

            steps {
                sh '''
                npm install netlify-cli
                node_modules/.bin/netlify --version
                node_modules/.bin/netlify status
                echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                node_modules/.bin/netlify deploy --dir=build --prod                
                npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    junit 'jest-results/junit.xml'
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}