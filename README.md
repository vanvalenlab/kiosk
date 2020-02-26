# DeepCell Kiosk: A Scalable and User-Friendly Environment for Biological Image Analysis

[![Build Status](https://travis-ci.com/vanvalenlab/kiosk.svg?branch=master)](https://travis-ci.com/vanvalenlab/kiosk)
[![Read the Docs](https://img.shields.io/readthedocs/kiosk?logo=Read%20the%20Docs)](https://deepcell-kiosk.readthedocs.io/en/master)
[![Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

The DeepCell Kiosk is the entry point for users to spin up an end-to-end DeepCell environment in the cloud using [Kubernetes](https://kubernetes.io/). It is designed to allow researchers to easily deploy and scale a deep learning platform for biological image analysis. Once launched, users can drag-and-drop images to be processed in parallel using publicly available, or custom-built, TensorFlow models. To train custom models, please refer to [DeepCell-TF](https://github.com/vanvalenlab/deepcell-tf), which was designed to facilitate model development and export these models for use with the DeepCell Kiosk.

The scalability of the DeepCell Kiosk software is enabled by [cloud computing](https://en.wikipedia.org/wiki/Cloud_computing). At present, the Kiosk is only compatible with [Google Cloud](https://cloud.google.com/).

A running example of the DeepCell Kiosk is live at [DeepCell.org](https://deepcell.org).

## Features

- Cloud-based deployment of deep-learning models
- Scalable platform that minimizes cost and inference time
- Drag and drop interface for running predictions

## Getting Started

Start a terminal shell and install the DeepCell Kiosk wrapper script:

```bash
docker run -e DOCKER_TAG=1.0.0 vanvalenlab/kiosk:1.0.0 | sudo bash
```

To start the kiosk, just run `kiosk` from the terminal shell.

Check out our [docs](https://deepcell-kiosk.readthedocs.io/en/master/GETTING_STARTED.html) for more information on how to start your own kiosk.

## Software Architecture

![Kiosk Architecture](https://raw.githubusercontent.com/vanvalenlab/kiosk/wg-docs-diagram/docs/images/Kiosk_Architecture.png)

- <a href="https://github.com/vanvalenlab/kiosk-frontend">Frontend</a>: API for creating and managing jobs, and a React-based DeepCell graphical user interface built using React, Babel, Webpack.

- <a href="https://github.com/vanvalenlab/kiosk-redis-consumer">Consumer</a>: Retrieves items from the Job Queue and handles the processing pipeline for that item. Each consumer only works on one item at a time.

- <a href="https://github.com/vanvalenlab/kiosk-tf-serving">Model Server</a>: Serves models over a gRPC API, allowing consumers to send data and get back predictions.

- <a href="https://github.com/vanvalenlab/kiosk-autoscaler">GPU Autoscaler</a>: Automatically and efficiently scales Kubernetes GPU resources.


## Contribute

We welcome contributions to the kiosk. If you are interested, please refer to our [Developer Documentation](https://deepcell-kiosk.readthedocs.io/en/master/DEVELOPER.html), [Code of Conduct](https://github.com/vanvalenlab/kiosk/blob/master/CODE_OF_CONDUCT.md) and [Contributing Guidelines](https://github.com/vanvalenlab/kiosk/blob/master/CONTRIBUTING.md).

## Support

Issues are managed through [Github](https://github.com/vanvalenlab/kiosk/issues).
Documentation is hosted on [Read the Docs](https://deepcell-kiosk.readthedocs.io/en/master).
A [FAQ](http://www.deepcell.org.faq) page is also available.

## License

This software is license under a modified [APACHE2](https://opensource.org/licenses/Apache-2.0). See [LICENSE](https://github.com/vanvalenlab/kiosk/blob/master/LICENSE) for full  details.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## Credits

[![Caltech Logo](https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg)](http://www.vanvalen.caltech.edu/)

This kiosk was developed with [Cloud Posse, LLC](https://cloudposse.com). They can be reached at <hello@cloudposse.com>

## Copyright

Copyright © 2018-2020 [The Van Valen Lab](http://www.vanvalen.caltech.edu/) at the California Institute of Technology (Caltech), with support from the Paul Allen Family Foundation, Google, & National Institutes of Health (NIH) under Grant U24CA224309-01.
All rights reserved.
