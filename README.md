## AWS Batch using Launch Template to create an ami with custome Space

This is built off [the case study by AWS](https://aws.amazon.com/blogs/compute/building-high-throughput-genomics-batch-workflows-on-aws-introduction-part-1-of-4/) specifically [creation of a custom ami](https://aws.amazon.com/blogs/compute/building-high-throughput-genomic-batch-workflows-on-aws-batch-layer-part-3-of-4/) where you use to be required to have a custom ami for AWS Batch.

We needed a less managed approach and the ```LaunchTempalate``` fulfills this requirement.

### Parameters
The parameters into this template are not required, but have been left in because this is part of a larger stack and allow us to copy and paste into another stack just replacing linting errors on non-created variables.

### LaunchTemplate
The launch template is the the core of allowing for managed, but modified ami's. This attribute takes two not 'required' but required parameters, an Id and [version](https://www.kindlyops.com/knowledge-base/cloudformation-launch-templates/).

```
Version: !GetAtt SpecialComputeLaunchTemplate.LatestVersionNumber
```


### AWS::ECS::LaunchTemplate
Per the nested [documentation on launch templates](https://docs.aws.amazon.com/batch/latest/userguide/launch-templates.html) the ```BlockDeviceMappings``` define a remote network storage device **AND** ```UserData``` which will created and attach network storage to an ECS instance.

The ```UserData``` needs to be Base64 encoded and since AWS Batch adds its own user data boundry, will have to be folded into 

```
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
```

```
--==MYBOUNDARY==
```
Where ```MYBOUNDARY``` is your own defined boundary name, ```BOUNDRY``` seems to be reserved to AWS Batch ECS own ECS cluster management so I would avoid that.

After this the volume will be attached and available, for the use in AWS Batch we need to go one more level and make this available in ```docker```.


### AWS::BatchJobDefinition
For the docker container to be able to see the volume which has been created and attached on EC2 instantiation , we need to add a docker mount/volume and add a working directory.

CloudFormation
```
MountPoints:
    - ContainerPath: "/data"
    ReadOnly: false
    SourceVolume: data
Volumes:
    - Name: data
    Host:
        SourcePath: "/data"
```

Where **SourcePath** is the only external value from the ```LaunchTemplate``` which you need, the other values are up to your choosing.

Second part is in the docker file
```
WORKDIR /data
```

Defines the working directy which we need to be the attached storage that is 250G.