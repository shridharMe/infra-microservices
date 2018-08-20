#!/usr/bin/env groovy
pipeline {
    agent {
        node { label 'docker' }
    }
      
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '14'))
        timestamps()
    }
    environment { 
        DOCKER_REPO_URL          = credentials('DOCKER_REPO_URL')        
        DOCKER_REPO_PWD          = credentials('DOCKER_REPO_PWD') 
        HOSTED_ZONE_NAME         = credentials('HOSTED_ZONE_NAME')
        TERRAFORM_USER_ARN       = credentials('TERRAFORM_USER_ARN')
        AWS_ACCESS_KEY_ID        = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY    = credentials('AWS_SECRET_KEY')  
        ENV_NAME                 = "dev" 
        SQUAD_NAME               = "devops"
    }
    parameters {
        booleanParam(name: 'REFRESH',defaultValue: true,description: 'Refresh Jenkinsfile and exit.')
       choice(choices: 'deploy\nteardown', description: 'Select option to create or teardown infro', name: 'TERRAFORM_ACTION')
    }
    stages {
        stage("install dependencies") {
            when {
                expression { params.REFRESH == false }     
                 expression { params.TERRAFORM_ACTION == "deploy" }                                        
            }					
            steps {
                dir('app-code') {
                sh '''             
                  make libs
                '''
                 }
            }
		}
         stage("testing") {
            when {
                expression { params.REFRESH == false }       
                 expression { params.TERRAFORM_ACTION == "deploy" }                                      
            }	
             parallel {
                  stage("sonar testing") {	
                       steps {
                                sh '''             
                                echo sonar testing
                                '''
                        }
                  }
                  stage("static security testing") {	
                       steps {
                                sh '''             
                                echo static security testing
                                '''
                        }
                  }
                  stage("unit testing") {	
                       steps {
                             dir('app-code') {
                                sh '''             
                                 make test
                                '''
                             }
                        }
                  }
                  stage("dependency check nexus lifecycle") {	
                       steps {
                                sh '''             
                                echo dependency check nexus lifecycle
                                '''
                        }
                  }
           
             }				
            
		}
        stage("build") {
            when {
                expression { params.REFRESH == false }     
                expression { params.TERRAFORM_ACTION == "deploy" }                                        
            }					
            steps {
                dir('app-code') {
                sh '''             
                  make clean all
                '''
                 }
            }
		}
        stage('docker build') {
            when {
                expression { params.REFRESH == false }
                 expression { params.TERRAFORM_ACTION == "deploy" }         
            }
            parallel {
                stage("front-end") {				
					steps {
                        dir('app-code/front-end') {
                        sh '''  
                        cp -R ../build build  
                         cp ../Makefile .                      
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=front-end docker-build 
                        '''
					}
                    }
				}
                stage("newsfeed") {				
					steps {
                     dir('app-code/newsfeed') {
						 sh ''' 
                          cp -R ../build build 
                           cp ../Makefile .                    
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=newsfeed docker-build 
                        '''
                     }
					}
				}
                stage("quotes") {					
					steps {
                         dir('app-code/quotes') {
						 sh '''
                           
                          cp -R ../build build 
                          cp ../Makefile . 
                          make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=quotes docker-build           
						  
                        '''
                         }
					}
				}
            }
           
        }
        stage('docker tagging') {
            when {
                expression { params.REFRESH == false }
                 expression { params.TERRAFORM_ACTION == "deploy" }         
            }
             parallel {
                stage("front-end") {
					 
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=front-end TAG=latest docker-tag
                        '''
                         }
					}
				}
                stage("newsfeed") {					
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=newsfeed TAG=latest docker-tag
                        '''
                         }
					}
				}
                stage("quotes") {					
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=quotes TAG=latest docker-tag
                        '''
                         }
					}
				}
            }            
        }
        stage('docker scanning') {
            when {
                expression { params.REFRESH == false }
                 expression { params.TERRAFORM_ACTION == "deploy" }                                    
            }
            parallel {
                stage("front-end") {					
					steps {
                         dir('app-code') {
						sh 'make docker-scanning'
                         }
					}
				}
                stage("newsfeed") {				
					steps {
                         dir('app-code') {
						sh 'make docker-scanning'
                         }
					}
				}
                stage("quotes") {				
					steps {
                         dir('app-code') {
						sh 'make docker-scanning'
                         }
					}
				}
            } 
            
        } 
        stage("run app") {
            when {
                expression { params.REFRESH == false }   
                expression { params.TERRAFORM_ACTION == "deploy" }                                   
            }					
            steps {
                 dir('app-code') {
                sh '''             
                   make run-docker-compose
                '''
                 }
            }
		}
        stage("owasp testing") {
            when {
                expression { params.REFRESH == false }     
                 expression { params.TERRAFORM_ACTION == "deploy" }                                        
            }					
            steps {
                 dir('app-code') {
                sh '''                            
                  make owsap-testing
                '''
                 }
            }
		}
        stage("docker login") {
            when {
                expression { params.REFRESH == false }  
                 expression { params.TERRAFORM_ACTION == "deploy" }                                           
            }					
            steps {
                 dir('app-code') {
                sh '''             
                   make DOCKER_REPO_URL=${DOCKER_REPO_URL} DOCKER_REPO_PWD=${DOCKER_REPO_PWD} docker-login
                '''
                 }
            }
		}
        stage('docker push') {
            when {
                expression { params.REFRESH == false }    
                 expression { params.TERRAFORM_ACTION == "deploy" }                                
            }
            parallel {
                stage("front-end") {					
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=front-end TAG=latest docker-push
                        '''
                        }
					}
				}
                stage("newsfeed") {
					steps {
                         dir('app-code') {
						  sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=newsfeed TAG=latest docker-push
                        '''
                         }
					}
				}
                stage("quotes") {
					steps {
                         dir('app-code') {
						  sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=quotes TAG=latest docker-push
                        '''
                         }
					}
				}
            }            
            
        }
    }
    post { 
        always {
            script{
                   
                          sh '''  
                          
                           docker system prune -f       
                           docker  network rm local_network                                      
                         '''   
                
            }
        }
        success { 
              script {
                      sh '''

                       echo " build successfull "
                      '''
                }
        }
        failure {
            script {
                    
                      sh '''
                       echo " build failed "
                      '''
             }
        }
    }
}


