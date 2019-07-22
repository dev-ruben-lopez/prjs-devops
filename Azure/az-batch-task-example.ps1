#create a resource group, storage account an then batch acount related. Using az commands in console.

#create the resource group
az group create --name AdelaideRLopezResGroup02 --location eastus2

#create the storage account
az storage account create --resource-group AdelaideRLopezResGroup02 --name storaccforbatchproc1 --location eastus2 --sku Standard_LRS



#Now, create the batch account and relate it to the storage account
az batch account create --name batchacc01 --storage-account storaccforbatchproc1 --resource-group AdelaideRLopezResGroup02 --location eastus2

#To create and manage compute pools and jobs, you need to authenticate with Batch. 
#Log in to the account with the az batch account login command. 
#After you log in, your az batch commands use this account context.

#Now that you have a Batch account, create a sample pool of Linux compute nodes using the az batch pool create command. 
#The following example creates a pool named mypool of 2 size Standard_A1_v2 nodes running Ubuntu 16.04 LTS. 
#The suggested node size offers a good balance of performance versus cost for this example.

az batch pool create --id mypool --vm-size Standard_A1_v2 --target-dedicated-nodes 2 --image canonical:ubuntuserver:16.04-LTS --node-agent-sku-id "batch.node.ubuntu 16.04" 

#Batch creates the pool immediately, but it takes a few minutes to allocate and start the compute nodes.
#During this time, the pool is in the resizing state. To see the status of the pool, run the az batch pool show command.

az batch pool show --pool-id mypool --query "allocationState"


#Now that you have a pool, create a job to run on it. A Batch job is a logical group for one or more tasks. 
#A job includes settings common to the tasks, such as priority and the pool to run tasks on. Create a Batch 
#job by using the az batch job create command. The following example creates a job myjob on the pool mypool. 
#Initially the job has no tasks.

az batch job create --id myjob --pool-id mypool


#The following Bash script creates 4 parallel tasks (mytask1 to mytask4).

for i in {1..4}
do
   az batch task create \
    --task-id mytask$i \
    --job-id myjob \
    --command-line "/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'"
done
#The command output shows settings for each of the tasks. Batch distributes the tasks to the compute nodes.
#To list the files created by a task on a compute node, use the az batch task file list command. The following command lists the files created by mytask1:
az batch task file list --job-id myjob --task-id mytask1 --output table

#to save one of the files :
az batch task file download --job-id myjob --task-id mytask1 --file-path stdout.txt --destination ./stdout.txt

