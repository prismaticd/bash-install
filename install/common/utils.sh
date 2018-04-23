#!/usr/bin/env bash


slugify() {
    echo $1 | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z
}

#slugify "www.prismaticdigital.com"
