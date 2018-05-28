#!/bin/bash

cd ../shopfront
mvn clean install
if docker build -t cbonami/shopfront . ; then
  docker push cbonami/shopfront
fi
cd ../shop

cd ../productcatalogue
mvn clean install
if docker build -t cbonami/productcatalogue . ; then
  docker push cbonami/productcatalogue
fi
cd ../shop

cd ../stockmanager
mvn clean install
if docker build -t cbonami/stockmanager . ; then
  docker push cbonami/stockmanager
fi
cd ../shop