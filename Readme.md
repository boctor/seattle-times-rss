# Seattle Times custom RSS feed

A custom RSS feed for [The Seattle Times](https://www.seattletimes.com) that excludes all syndicated content and only includes articles created by The Seattle Times staff.

## Getting Started

Load https://rss.theappuniverse.com/seattletimes.xml in your favorite RSS reader.

### About

A very simple ruby script loads the official RSS feed and iterates through each element deciding wether to include it in the custom RSS feed.

The script excludes any entries that have the following categories: Explore, Sponsored and Diversions.

For all other entries, the article URL is loaded and only included if the source meta tag isn't a syndicated source.

### Deployment Setup

The script is deployed as an [AWS Lambda](https://aws.amazon.com/lambda/) function which is periodically invoked via cron using [CloudWatch Events](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/Create-CloudWatch-Events-Scheduled-Rule.html).

[AWS Memcached/ElastiCache](https://aws.amazon.com/elasticache/memcached/) is used to cache loaded URLs so if the same article appears in the official RSS feed, the article URL is only loaded once.

After the official RSS feed is processed, the new custom RSS feed is saved to S3 where all RSS feed readers are pointed. [Cloudflare](https://www.cloudflare.com) is used to provide SSL and alias the custom feed URL to the S3 URL.

### Deployment

[Nokogiri](https://nokogiri.org) is used to parse the HTML for each article and determine the source meta tag.
Since Nokogiri uses native extensions, deploying it to AWS Lambda requires an extra step of compiling the native extensions against the flavor of Linux that AWS Lambda uses.

To do this, install docker and follow the directions in [Using Ruby-Gems with Native Extensions on AWS Lambda](https://blog.francium.tech/using-ruby-gems-with-native-extensions-on-aws-lambda-aa4a3b8862c9):

```
cd seattle_times
docker run -it --rm -v "$PWD":/var/task lambci/lambda:build-ruby2.5 bash
bundle install --deployment
```
Deploying to Lambda can be done using the [AWS CLI](https://aws.amazon.com/cli/). First all the relevant files are zipped and then uploaded to Lambda:

zip -r seattletimes.zip lambda_function.rb seattle_times_rss_parser.rb vendor
aws lambda update-function-code --function-name seattletimes --zip-file fileb://seattletimes.zip

To manually kick off Lambda execution:
aws lambda invoke --function-name seattletimes response.json

## Running the tests

A single test iterates thru example feed items, testing whether they would be included or excluded from the custom feed.

To run the tests:

```
rake spec
```

## Running locally

To run the RSS parsing and filtering, run

```
rake
```

The resutling custom feed will be printed to stdout.

## Authors

[Peter Boctor](https://github.com/boctor)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

