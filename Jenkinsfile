pipeline {
    agent any
    
    environment {
        GIT_REPO = 'https://github.com/YOUR_USERNAME/YOUR_REPO.git'
        GITHUB_REPO = 'YOUR_USERNAME/YOUR_REPO'
        DEPLOY_DIR = "${WORKSPACE}/deploy"
        COMPOSE_FILE = "${WORKSPACE}/docker-compose.test.yml"
        EMAIL_RECIPIENT = 'your-email@example.com'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout the PR branch
                    checkout scm
                    sh '''
                        echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
                        echo "Commit: $(git rev-parse HEAD)"
                    '''
                }
            }
        }
        
        stage('Build Test Cluster') {
            steps {
                script {
                    sh '''
                        chmod +x scripts/*.sh
                        ./scripts/build.sh
                    '''
                }
            }
        }
        
        stage('Deploy Code') {
            steps {
                script {
                    sh './scripts/deploy.sh'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    try {
                        sh './scripts/test.sh'
                        currentBuild.result = 'SUCCESS'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
        
        stage('Merge PR') {
            when {
                expression { 
                    currentBuild.result == 'SUCCESS' && 
                    env.CHANGE_ID != null 
                }
            }
            steps {
                script {
                    // Auto-merge PR if tests pass
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            echo "Tests passed! Merging PR #${CHANGE_ID}..."
                            export GITHUB_TOKEN="${GITHUB_TOKEN}"
                            export GITHUB_REPO="${GITHUB_REPO}"
                            export PR_NUMBER="${CHANGE_ID}"
                            chmod +x scripts/merge-pr.sh
                            ./scripts/merge-pr.sh || echo "Merge failed or PR already merged"
                        '''
                    }
                }
            }
        }
        
        stage('Cleanup') {
            always {
                script {
                    sh './scripts/cleanup.sh'
                }
            }
        }
    }
    
    post {
        success {
            emailext(
                subject: "CI/CD Pipeline SUCCESS: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    Pipeline Status: SUCCESS
                    Job: ${env.JOB_NAME}
                    Build Number: ${env.BUILD_NUMBER}
                    Branch: ${env.BRANCH_NAME}
                    Commit: ${env.GIT_COMMIT}
                    
                    All tests passed successfully!
                """,
                to: "${env.EMAIL_RECIPIENT}"
            )
        }
        failure {
            emailext(
                subject: "CI/CD Pipeline FAILED: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    Pipeline Status: FAILED
                    Job: ${env.JOB_NAME}
                    Build Number: ${env.BUILD_NUMBER}
                    Branch: ${env.BRANCH_NAME}
                    Commit: ${env.GIT_COMMIT}
                    
                    Please check the build logs for details.
                """,
                to: "${env.EMAIL_RECIPIENT}"
            )
        }
    }
}

