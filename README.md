# DeepCell Kiosk: Deploying a Scalable Solution for Biological Image Analysis

This DeepCell distribution is designed to easily spin up an end-to-end DeepCell environment on Kubernetes. The repository contains shell scripts and configuration files that follow the infrastructure-as-code model to easily manage and scale a deep learning solution for biological image analysis.  

Once running, the Kiosk iniates a web portal that has access to a cluster of computers in the cloud. This distribution is managed automatically by Kubernetes (deployment software also launched by the Kiosk at run-time). The web portal allows multiple users to upload mulitple images (in the form of zip files) and download the resulting segmentation and classification of these images automatically. An example of this deployment and web portal is at [deepcell.org](https://deepcell.org).

## Before starting the Kiosk

The scalability of the software is enabled by cloud computing. As such, the preparation steps vary depending on which cloud provider you plan on deploying with:

#### Google Cloud

1. Create an account at [Google Cloud](https://cloud.google.com).
2. Create a Google Cloud project.
3. Make sure you have at least one account with the `Owner` role.
4. Make sure you have a storage bucket with public access.
5. Make sure that any files you upload to the bucket (such as pre-trained Tensorflow models) have public access. (Google Cloud uses a permission system that may be unfamiliar to Linux users. File permissions are not inherited from buckets; they are set individually on each file.)

#### Amazon Web Services

1. Create an account at [Amazon Web Services](https://aws.amazon.com).
2. Make sure you have at least one account which is a member of the `admin` group.
3. You should generate an access key pair for this `admin` account using the instructions found [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
4. Make sure you have a S3 bucket with public access.

## Kiosk startup

#### Windows Users

1. [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (Windows Subsystem for Linux)

#### All Users (Windows and otherwise)

1. Install [Docker for your OS](https://www.docker.com/community-edition) (*FREE Community Edition*).
2. Start a terminal shell
3. Install the Deepcell kiosk wrapper script: `docker run vanvalenlab/kiosk:0.3.0 | sudo -E bash -s 0.3.0`
4. Start the kiosk. Just run: `kiosk`
5. Follow setup instructions, when prompted

## Kiosk usage

1. Once the Kiosk has started, select the configuration option for your chosen cloud provider, either Amazon or Google, and fill out the configuration values as needed. ( If using Google, follow the link provided during the configuration process in a web browser.) Once the Kiosk has been configured for a cloud provider, the word `(active)` will appear next to that cloud provider's configuration option in the Kiosk menu.
2. With the Kiosk configured for the appropriate cloud provider, select the `Create` option from the Kiosk's main menu to create the cluster on the chosen cloud provider. This may take up to 10 minutes. Cluster creation is done when you see `Cluster Created` followed by `---COMPLETE---` printed to the terminal. If you see `---COMPLETE---` with some error text immediately preceding it, cluster creation failed.
3. Find the cluster's web address by choosing the `View` option form the Kiosk's main menu. (Depending on your chosen cloud provider and the cloud provider's settings, your cluster's address might be either a raw IP address, e.g., "123.456.789.012", or a URL, e.g., "deepcellkiosk.cloudprovider.com".
4. Go to the cluster address in your web browser to find the Deepcell frontpage.

## Kiosk shutdown

When you're done using the cluster, you may want to shutdown the cluster, and perhaps the kiosk itself.
1. To shutdown the cluster, select `Destroy` from the Kiosk's main menu. Cluster destruction is complete when you see `Cluster destroyed` followed by `---COMPLETE---` printed to the screen. However, if the screen shows error output immediately before the `---COMPLETE---` indicator, cluster destruction failed and some components may remain. In this case, it may be best to delete resources manually though the cloud provider's web interface.
2. After shutting down the cluster, if you wish to shut down the kiosk, simply select `Exit` form the Kiosk's main menu. The Kiosk is now completely shut down.

## Notes

- When using the `Predict` functionality, the first image will take a while to process (up to 10 minutes) because the cluster will need to requisition more computing resources. (This is because the cluster is designed to use as few resources as possible in its resting state.)
- This repository is being actively developed. If you are experiencing issues with the Deepcell kiosk, please consult the [Troubleshooting document](docs/TROUBLESHOOTING.md) in the `docs` folder.
- Those interested in Kiosk developement should follow a different path to start the Kiosk:
    1. Clone this repo: `git clone git@github.com:vanvalenlab/kiosk.git`
    2. Initialize the "build-harness": `make init`
    3. Build the container: `make docker/build`
    4. Install wrapper script: `make install`
    5. Start the kiosk. `make run`


## Accessing Cluster Logging and Metrics Functionality using OpenVPN
1. After cluster startup, choose `Shell` from the main menu. On the command line, execute the following command:

```bash
POD_NAME=`kubectl get pods --namespace=kube-system -l type=openvpn | awk END'{ print $1 }'` \
&& kubectl logs --namespace=kube-system $POD_NAME
```

If the OpenVPN pod has already deployed, you should see something like "Mon Apr 29 21:15:53 2019 Initialization Sequence Completed" somewhere in the output.

2. If you see that line, then execute

```bash
POD_NAME=`kubectl get pods --namespace kube-system -l type=openvpn | awk END'{ print $1 }'` \
&& SERVICE_NAME=`kubectl get svc --namespace kube-system -l type=openvpn | awk END'{ print $1 }'` \
&& SERVICE_IP=$(kubectl get svc --namespace kube-system $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}') \
&& KEY_NAME=kubeVPN \
&& kubectl --namespace kube-system exec -it $POD_NAME /etc/openvpn/setup/newClientCert.sh $KEY_NAME $SERVICE_IP \
&& kubectl --namespace kube-system exec -it $POD_NAME cat /etc/openvpn/certs/pki/$KEY_NAME.ovpn > $KEY_NAME.ovpn
```

3. Then, copy the newly-generated `kubeVPN.ovpn` file onto your local machine. (You can do this either by viewing the file's contents and copy-pasting them manually, or by using a file-copying tool like SCP.)

4. Next, using an OpenVPN client locally, connect to the cluster using `openvpn --config kubeVPN.ovpn` as your config file. You may need to use `sudo` if the above does not work.

5. Once inside the cluster, you can connect to Kibana (logging) and Grafana (monitoring) by going to `[service_IP]:[service_port]` for the relevant service from any web browser on your local machine. (To view the service ports and IPs, execut the command `kubectl get svc --all-namespaces` from the kiosk's command line.)


## References
- [Cluster Autoscaler for AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)
- [Cluster Autoscaler for Kops](https://github.com/kubernetes/kops/blob/master/addons/cluster-autoscaler/)
- [Running GPU Intances on Kops](https://github.com/brunsgaard/kops-nvidia-docker-installer)

## Copyright

Copyright © 2018-2019 [The Van Valen Lab](http://www.vanvalen.caltech.edu/) at the California Institute of Technology (Caltech), with support from the Paul Allen Family Foundation, Google, & National Institutes of Health (NIH) under Grant U24CA224309-01.  
All rights reserved.

## License

This software is licensed under a modified [APACHE2](LICENSE).

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## Credits

[![Van Valen Lab, Caltech](https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg)](http://www.vanvalen.caltech.edu/)

This kiosk was developed with [Cloud Posse, LLC](https://cloudposse.com). They can be reached at <hello@cloudposse.com>

[![Cloud Posse](https://cloudposse.com/logo-300x69.svg)](https://cloudposse.com)

We're a [DevOps Professional Services](https://cloudposse.com) company based in Los Angeles, CA. We love [Open Source Software](https://github.com/cloudposse/)!
