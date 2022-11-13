# Client CMS

Author: Lucas Pichette

## Adding Another Client

I've set this up so that you can run the following and be set up:

- `mkdir {x}`
- `cp template/* {x}`
- `terraform ...`

## Zipping Lambdas

It's critical the filename is the same as the handler in aws_lambda_function.

It's critical the function name is lambda_handler().

The Lambda name can be whatever.

Your Python function should be a folder with the same name as the filename.

To zip your .py file, run:

zip -r <filename.zip> foldername
