pipeline {
    agent any
    
    environment {
        GITHUB_TOKEN = credentials('github-token')
        REPO_OWNER = 'alinasser4'
        REPO_NAME = 'devops'
        PROJECT_DIR = '/opt/devops'
    }
    
    stages {
        stage('Validate PR') {
            steps {
                script {
                    // Check if this is a valid PR trigger
                    if (env.PR_NUMBER == null || env.PR_NUMBER == '') {
                        echo "No PR number - this is a manual build"
                        env.IS_PR_BUILD = 'false'
                    } else {
                        echo "PR #${env.PR_NUMBER} detected"
                        echo "PR Branch: ${env.PR_BRANCH}"
                        echo "PR Action: ${env.PR_ACTION}"
                        echo "Base Branch: ${env.PR_BASE}"
                        
                        // Only proceed if PR is opened/synchronize and targets main
                        if (env.PR_ACTION == 'opened' || env.PR_ACTION == 'synchronize' || env.PR_ACTION == 'reopened') {
                            if (env.PR_BASE == 'main') {
                                echo "Valid PR to main branch - proceeding with CI/CD"
                                env.IS_PR_BUILD = 'true'
                            } else {
                                echo "PR targets ${env.PR_BASE}, not main - skipping"
                                env.IS_PR_BUILD = 'false'
                            }
                        } else {
                            echo "PR action is ${env.PR_ACTION} - skipping (only process opened/synchronize/reopened)"
                            env.IS_PR_BUILD = 'false'
                        }
                    }
                }
            }
        }
        
        stage('Checkout PR Branch') {
            when {
                expression { return env.IS_PR_BUILD == 'true' || env.PR_NUMBER == null || env.PR_NUMBER == '' }
            }
            steps {
                sh '''
                    echo "=== Checking out code ==="
                    cd ${PROJECT_DIR}
                    git config --global --add safe.directory ${PROJECT_DIR}
                    git fetch origin
                    
                    if [ -n "${PR_BRANCH}" ] && [ "${IS_PR_BUILD}" = "true" ]; then
                        echo "Checking out PR branch: ${PR_BRANCH}"
                        git checkout ${PR_BRANCH} || git checkout -b ${PR_BRANCH} origin/${PR_BRANCH}
                        git pull origin ${PR_BRANCH} || true
                    else
                        echo "Checking out main branch"
                        git checkout main
                        git pull origin main
                    fi
                    
                    echo "=== Checkout complete ==="
                    sleep 2
                '''
            }
        }
        
        stage('Build Images') {
            when {
                expression { return env.IS_PR_BUILD == 'true' || env.PR_NUMBER == null || env.PR_NUMBER == '' }
            }
            steps {
                sh '''
                    echo "=== Building Docker images ==="
                    cd ${PROJECT_DIR}
                    docker compose build --no-cache
                    echo "=== Build complete ==="
                    sleep 3
                '''
            }
        }
        
        stage('Start Testing Cluster') {
            when {
                expression { return env.IS_PR_BUILD == 'true' || env.PR_NUMBER == null || env.PR_NUMBER == '' }
            }
            steps {
                sh '''
                    echo "=== Cleaning up old containers ==="
                    cd ${PROJECT_DIR}
                    docker compose down --remove-orphans || true
                    sleep 5
                    
                    echo "=== Starting MySQL container ==="
                    docker compose up -d mysql
                    echo "Waiting for MySQL to initialize..."
                    sleep 30
                    
                    echo "=== Checking MySQL health ==="
                    docker compose ps mysql
                    
                    echo "=== Starting PHP container ==="
                    docker compose up -d php
                    echo "Waiting for PHP/Apache to start..."
                    sleep 15
                    
                    echo "=== Checking PHP health ==="
                    docker compose ps php
                    
                    echo "=== Final cluster status ==="
                    docker compose ps
                    sleep 5
                '''
            }
        }
        
        stage('Verify Services') {
            when {
                expression { return env.IS_PR_BUILD == 'true' || env.PR_NUMBER == null || env.PR_NUMBER == '' }
            }
            steps {
                sh '''
                    echo "=== Verifying services are responding ==="
                    cd ${PROJECT_DIR}
                    sleep 5
                    
                    echo "Testing PHP container health..."
                    for i in 1 2 3 4 5; do
                        if docker exec test-php curl -s http://localhost/index.php > /dev/null 2>&1; then
                            echo "PHP is responding!"
                            break
                        fi
                        echo "Waiting for PHP... attempt $i"
                        sleep 5
                    done
                    
                    echo ""
                    echo "=== Home Page Response ==="
                    docker exec test-php curl -s http://localhost/index.php | head -10
                    
                    sleep 3
                    
                    echo ""
                    echo "=== API Response ==="
                    docker exec test-php curl -s http://localhost/api.php
                    
                    echo ""
                    echo "=== Services verified ==="
                    sleep 3
                '''
            }
        }
        
        stage('Run Tests') {
            when {
                expression { return env.IS_PR_BUILD == 'true' || env.PR_NUMBER == null || env.PR_NUMBER == '' }
            }
            steps {
                sh '''
                    echo "=== Running unit tests ==="
                    cd ${PROJECT_DIR}
                    sleep 5
                    docker compose run --rm nodejs
                    echo "=== Tests complete ==="
                '''
            }
        }
        
        stage('Merge PR') {
            when {
                expression { 
                    return env.IS_PR_BUILD == 'true' && env.PR_NUMBER != null && env.PR_NUMBER != ''
                }
            }
            steps {
                sh '''
                    echo "=== Tests passed! Merging PR #${PR_NUMBER} into main ==="
                    
                    MERGE_RESPONSE=$(curl -s -X PUT \
                        -H "Authorization: token ${GITHUB_TOKEN}" \
                        -H "Accept: application/vnd.github.v3+json" \
                        https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/pulls/${PR_NUMBER}/merge \
                        -d '{"commit_title":"Auto-merge PR #'${PR_NUMBER}' after successful CI tests","merge_method":"merge"}')
                    
                    echo "GitHub API Response: ${MERGE_RESPONSE}"
                    
                    if echo "${MERGE_RESPONSE}" | grep -q '"merged":true'; then
                        echo "=== SUCCESS: PR #${PR_NUMBER} merged into main! ==="
                    elif echo "${MERGE_RESPONSE}" | grep -q '"message":"Pull Request is not mergeable"'; then
                        echo "=== WARNING: PR has conflicts or is not mergeable ==="
                    else
                        echo "=== Merge response received - check GitHub for status ==="
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            sh '''
                echo "=== Cleaning up ==="
                cd ${PROJECT_DIR}
                sleep 2
                docker compose down --remove-orphans || true
                sleep 3
                echo "=== Cleanup complete ==="
            '''
        }
        success {
            echo '=== BUILD SUCCESSFUL - All tests passed! ==='
        }
        failure {
            echo '=== BUILD FAILED - Check logs for details ==='
        }
    }
}
