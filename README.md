# AWS Static Site

This project is a small static site hosted from an S3 bucket via cloudfront.

## Installation

Run `terraform init` from the `deploy` folder.

## Deployment

From the `deploy` directory run `terraform apply`

## Accessing the Website

The deployment outputs a url that can be used to access the site
(it can be found post deployment using `terraform output url`).

The site can only be accessed via the IW VPN.