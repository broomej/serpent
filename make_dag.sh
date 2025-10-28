#! /usr/bin/env bash
snakemake --dag | dot -Tsvg > images/dag.svg
