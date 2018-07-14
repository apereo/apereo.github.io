#!/bin/bash
bundle exec jekyll build
bundle exec jekyll serve --incremental --future --unpublished
