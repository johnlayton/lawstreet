#!/usr/bin/env zsh

. ~/.zshrc

logger title "Initialisation"

logger info "Create and start kube"
kube init

logger title "Prerequisites"

logger info "Add the flux chart repo (and list repos)"
helm repo add fluxcd https://charts.fluxcd.io
helm repo list

logger info "Create the flux namespace and install flux"
kubectl create ns flux
helm upgrade -i flux fluxcd/flux --wait \
  --namespace flux \
  --set registry.pollInterval=1m \
  --set git.pollInterval=1m \
  --set git.url=git@github.com:johnlayton/lawstreet

logger info "Get the deployment key and add to repo"
fluxctl identity --k8s-fwd-ns flux
open "http://github.com/johnlayton/lawstreet/settings/keys"

logger info "Install the helm operator"
helm upgrade -i helm-operator fluxcd/helm-operator --wait \
  --namespace flux \
  --set git.ssh.secretName=flux-git-deploy \
  --set git.pollInterval=1m \
  --set chartsSyncInterval=1m \
  --set helm.versions=v3
