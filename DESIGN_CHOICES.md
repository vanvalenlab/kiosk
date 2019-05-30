```filenaming conventions```
- input files (direct and via web interface)

```microservice architecture```

```database conventions```
This is purely backend documentation, so it might be irrelevant to many users. However, any future developers working with this codebase might appreciate some insight into our design decisions.
We've decided to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.
- write originating pod and timestamp for every status change
- move all fields to "old_" prefixed fields upon status reset
- increment "status_reset" counter upon status reset
- not using a queue currently, partly to help debug failures, partly to accord with our own tendency towards indolence


TROUBLESHOOTING:
If your predictions keep failing and you have a lot of models (or model versions) in your `models` folder, you could be experiencing a memory issue involving Tensorflow-Serving. The solution is to reduce the number of models or model versions you have in your models` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models,or, if possible, submitting smaller images for prediction. In our experience, using n1-highmem-2 and n1-highmem-4 instances, we ran into issues when we had more than ~10 model versions total across all models in the `models` folder. Your mileage may vary based on a variety of factors.
