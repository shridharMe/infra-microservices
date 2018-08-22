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
        AWS_ACCESS_KEY_ID        = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY    = credentials('AWS_SECRET_KEY')  
        ENV_NAME                 = "dev" 
        SQUAD_NAME               = "devops"
    }
    parameters {
         
       booleanParam(name: 'BUILD',
            defaultValue: true, 
            description: 'select this option to build the code.( it is enabled by default)\n\n----------------------------------------------------------------\n\n To deploy the code please select image version from below list')       
       
       choice(choices: 'latest\n', description: 'select docker image version', name: 'IMAGE_VERSION')
       
       choice(choices: 'provision\nteardown', description: 'provision action; first creates the new environment (if it does not exist) and then do the deploy  \n\n select environment from below list to provision or destroy \n----------------------------------------------------------------', name: 'ACTION_ON_ENV')
       
        booleanParam(name: 'DEV',
        defaultValue: true,
        description: '' ) 

        booleanParam(name: 'INT',
        defaultValue: false,
        description: '')
    }
    stages {
        stage("install dependencies") {
            when {
               // expression { params.REFRESH == false }     
                 expression { params.BUILD == true }   
                expression { params.ACTION_ON_ENV == 'provision' }                                     
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
                  expression { params.ACTION_ON_ENV == 'provision' }        
                  expression { params.BUILD == true }                                          
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
                 expression { params.ACTION_ON_ENV == 'provision' }    
                 expression { params.BUILD == true }                                             
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
                   expression { params.ACTION_ON_ENV == 'provision' } 
                 expression { params.BUILD == true }           
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
                   expression { params.ACTION_ON_ENV == 'provision' }
                  expression { params.BUILD == true }           
            }
             parallel {
                stage("front-end") {
					 
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=front-end TAG=${IMAGE_VERSION} docker-tag
                        '''
                         }
					}
				}
                stage("newsfeed") {					
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=newsfeed TAG=${IMAGE_VERSION} docker-tag
                        '''
                         }
					}
				}
                stage("quotes") {					
					steps {
                         dir('app-code') {
						 sh '''                       
						  make DOCKER_REPO_URL=${DOCKER_REPO_URL} APP_NAME=quotes TAG=${IMAGE_VERSION} docker-tag
                        '''
                         }
					}
				}
            }            
        }
        stage('docker scanning') {
            when {
                  expression { params.ACTION_ON_ENV == 'provision' } 
                  expression { params.BUILD == true }                                    
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
                  expression { params.ACTION_ON_ENV == 'provision' }  
                expression { params.BUILD == true }                                        
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
           expression { params.ACTION_ON_ENV == 'provision' }     
                 expression { params.BUILD == true }                                             
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
                 expression { params.ACTION_ON_ENV == 'provision' }  
                expression { params.BUILD == true }                                              
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
                  expression { params.ACTION_ON_ENV == 'provision' }    
                 expression { params.BUILD == true }                                     
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
        stage('Provision Dev env') {
            when {
                //expression { params.REFRESH == false }
                expression { params.ACTION_ON_ENV == 'provision' }
                expression { params.DEV == true }
            }
            steps {
                dir('infra/core') {
                sh  '''   
                    cp ../provision.sh .
                    chmod +x ./provision.sh                                 
                    ./provision.sh -e dev -r init
                    ./provision.sh -e dev -r validate
                    ./provision.sh -e dev -r plan
                    ./provision.sh -e dev -r apply
                    '''
                }
            }
        } 
        stage('teardown Dev env') {
            when {
                //expression { params.REFRESH == false }
                expression { params.ACTION_ON_ENV == 'teardown' }
                expression { params.DEV == true }
            }
            steps {
                dir('infra/core') {
                sh  '''   
                    cp ../provision.sh .
                    chmod +x ./provision.sh                                 
                    ./provision.sh -e dev -r init
                    ./provision.sh -e dev -r validate
                    ./provision.sh -e dev -r plan
                    ./provision.sh -e dev -r destroy
                    '''
                }
            }
        } 
    }
    post { 
        always {
            script{
                   
                          sh '''  
                                                    
                            docker system prune -f                                                
                                                              
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