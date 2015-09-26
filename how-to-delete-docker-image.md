# How to Delete Docker Image from Private Docker Registry

## Pre-Requisite
* Docker registry version is 2.1.1
* ssh access to the private docker registry host with root privilege (For orion environment, the host to login to is one of the web instances)
* curl is installed on the private docker registry host

## Steps
1. Make sure `delete` is enabled in the docker registry configuration. See [this](https://github.com/docker/distribution/blob/master/docs/configuration.md#delete) for detail on how to enable delete. Restart the registry if registry config file is updated.

2. Find out the `digest` of the image to be delete using the following command

        curl -vv -XGET localhost:5000/v2/labserver/manifests/somboon
        
    > * In this example, the image to remove is `registry.oriontest.net/labserver:somboon`
    
    > * The `digest` information will be in the HTTP headers section of the output of the above command (e.g., `sha256:e5460f4ccf28b7ce865f9bb95761ae336c25ff5be059f92988049ecee13f657e`)

3. Issue the following curl command to remove the image 
        
        curl -XDELETE localhost:5000/v2/labserver/manifests/sha256:e5460f4ccf28b7ce865f9bb95761ae336c25ff5be059f92988049ecee13f657e
        
        
> NOTE: The above procedure is a `soft-delete` meaning it will remove access to the image from any docker command/API. However, the disk usage will
not be freed up. As of 09/25/2015, the `hard-delete` (removing images from storage backend) is not yet supported.

## Misc
If you see the following error, then `delete` is not yet enabled in registry config:
```
error:
[15:08] <s0mb00n> thanks @rscothern, here is the command I use `curl -XDELETE localhost:5000/v2/labserver/manifests/sha256:e5460f4ccf28b7ce865f9bb95761ae336c25ff5be059f92988049ecee13f657e` but I got the following error:  `{"errors":[{"code":"UNSUPPORTED","message":"The operation is unsupported."}]}`...
```

Below are chat archived from #docker-distribution IRC channel in [freenode](http://webchat.freenode.net/) regarding this:

```
[14:03] == s0mb00n [4a3efd82@gateway/web/freenode/ip.74.62.253.130] has joined #docker-distribution
[14:08] <s0mb00n> hello, does anyone know what's the recommended way to remove a tagged image in a private docker registry?
[14:23] <s0mb00n> I used s3 backend, can I just go and remove the directory with the tag name in the /v2/repositoreis/<repo_name>/manifests/tags/?
[14:24] <@dmp42> s0mb00n: you can delete the tag using the API
[14:24] <@dmp42> if you want to go to the backend, you will find the tag file as well, pointing to a digest on the blob store
[14:38] <s0mb00n> @dmp42: I find a directory in my s3 backend under /v2/repositoreis/<repo_name>/manifests/tags. do you mean I have to go look into the file in my tag directory and look into each file for the location of the images in the blob store?
[14:41] <@dmp42> s0mb00n: any reason not to use the delete API?
[14:46] <s0mb00n> @dmp42: no not at all, I just can't seem to find it :)
[14:47] <@dmp42> s0mb00n: that’s in there IIRC: https://github.com/docker/distribution/blob/master/docs/spec/api.md#deleting-an-image - you need to run registry-2.1.1 to have delete
[14:48] <@dmp42> and/or, from the bucket, you locate the tag you are interested in and delete the file, that should do
[14:49] <@dmp42> DISCLAIMER: messing up with your storage manually may have unexpected consequences, adverse effects on kittens, etc
[14:49] <s0mb00n> @dmp42 thank you, I'll give it a try, so just to confirm per the document the '<name>' is the repo name and '<reference>' is the tag, correct?
[14:50] <@dmp42> I would say <reference> is the digest of what you want to delete
[14:50] <@dmp42> rscothern: ^
[14:50] <rscothern> s0mboon: <reference> is the digest
[14:52] <s0mb00n> @dmp42 @rscothern: sorry for so many question, i'm basically a newbie here, where do I find this digest?
[14:53] <rscothern> you can get the digest from the HTTP headers when you get a manifest
[15:08] <s0mb00n> thanks @rscothern, here is the command I use `curl -XDELETE localhost:5000/v2/labserver/manifests/sha256:e5460f4ccf28b7ce865f9bb95761ae336c25ff5be059f92988049ecee13f657e` but I got the following error:  `{"errors":[{"code":"UNSUPPORTED","message":"The operation is unsupported."}]}`...
[15:08] <s0mb00n> does this mean I'm not using the latest v2 registry version?
[15:08] <rscothern> is delete enabled in your configuration?
[15:08] <rscothern> (it’s a storage parameter)
[15:10] <s0mb00n> I don't see it enable explicity, here is my config Mb57mr9a
[15:11] <s0mb00n> http://pastebin.com/Mb57mr9a
[15:12] <rscothern> https://github.com/docker/distribution/blob/master/docs/configuration.md#delete
[15:19] <s0mb00n> @rscothern, @dmp42: thanks again, I think I was able to delete the tag now
[15:19] <s0mb00n> however, the s3 folder with the tag name is still there
[15:20] <rscothern> this is just a soft delete, it is inaccessible with the API
[15:21] <rscothern> to truly recover space will require garbage collection
[15:22] <s0mb00n> @rscothern: ah..that explains it. No, this is good enough for me. thank you again so much
```
