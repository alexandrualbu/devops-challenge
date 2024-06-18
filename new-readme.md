
I've started by forking the code and clone it on my computer. I have created a new branch and started to create a simple Dockerfile, build it and enter in it to ensure that the application is running correctly. I have copied all the code in the container and tried to run the app and to execute a lint test there.
By running the lint I have noticed that eslint must be installed and also a eslint.config.js to be created and copied in the container.
After all the dependencies were installed, the elsint file was created and the lint script was added in package.json file, the application ran properly.

The most important modifications:
>npm install (dockerfile and github actions)
>npm install -g eslint (dockerfile and github actions)
>eslint.config.js: created
>package.json modification:  "lint": "eslint" (line added)

docker build -f Dockerfile -t qed
docker run -d -p 80:3000 qed

After that I have created ci.yaml file that build the Dockerfile and pushed it on dockerhub on every commit. All the dependencies must be in that github action file also.

I have continued with deploying using terraform an ec2 instance containing that application. I have created a single main.tf file. After the provider was set I have created an access key on aws. I have used it to access aws from terraform code in `provider "aws"`.


I have created a VPC, a subnet, a gateway and a route table and route table association to access the application from the outside using the public ip that was automatically generated.
I order to properly access the application ingress and egress rules were need to be set by creating a security group.

On the instance creation user_data was customized to update, install and pull, docker and docker image respectively.

After everything was set, a delay of 1 minute was needed to pass 2 test checks and see that the application is running on port 80 used on the ec2 instance.

>docker run -d -p 80:3000 alexalbu/qed ( ran on ec2 instance )
http://public-ip:80

Finally I have created the terraform gh action to deploy automatically and destroy the application after 2 minutes of running in aws.

For the github actions these secrets were mandatory.
ci.yaml file:
    DOCKER_PASSWORD
    DOCKER_USERNAME
deploy.yaml file:
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
