## Grafana Dashboard Generation Idea

New issue:

> As a metrics observer, I would like to define Grafana dashboards as code and check them into source control.

> The code would not be JSON. It would be in a configuration or programming language that would be able to output complete dashboard JSON. I'd like to define and own the absolute minimum amount of code.

How to proceed?

Such tools exist to facilitate this, however, the community is far from agreeing on a standard. This thread from over a year ago seems to accurately call out current competing standards:

[https://community.grafana.com/t/grafana-dashboards-as-code-for-newcomers/5334](https://community.grafana.com/t/grafana-dashboards-as-code-for-newcomers/5334)

These are probably the top three:

* [https://github.com/uber/grafana-dash-gen](https://github.com/uber/grafana-dash-gen)
* [https://github.com/weaveworks/grafanalib](https://github.com/weaveworks/grafanalib)
* [https://github.com/grafana/grafonnet-lib](https://github.com/grafana/grafonnet-lib)

I've even written such a tool myself in Ruby: [https://github.com/trotttrotttrott/grafana-dash-rb](https://github.com/trotttrotttrott/grafana-dash-rb).

They all pretty much cover the bases.

..

But I'm not writing to promote a specific tool. I'm writing to suggest that we've all got it wrong. Each solution probably works well enough for the individuals and teams who've adopted them. But none of them seem strong enough to become a standard.

It seems to me the issue is that they're each too deep in their respective lingual ecosystems - JavaScript, Python, Jsonnet, Ruby. Most folks will have a clear preference. The preference is likely based on which fits in better with their existing codebase and team familiarity.

### HTTP API Clients

HTTP APIs tend to have client libraries in various languages. For example the Grafana API has ones in [Ruby](https://github.com/hartfordfive/ruby-grafana-api), [Python](https://pypi.org/project/grafana-api/), [Go](https://github.com/nytm/go-grafana-api), [Java](https://github.com/appnexus/grafana-api-java-client), [Elixir](https://github.com/asconix/grafana_elixir), [NodeJS](https://www.npmjs.com/package/grafana-api-client), and probably others.

It's necessary because these libraries are going to be embedded into applications of various languages. Each of these client libraries are managed separately. When the Grafana API changes, each client library must be updated individually.

Similarly, the same is true for Grafana dashboard schema changes and the many existing dashboarding tools.

### Shared Data Among Tooling

To combat such isolated changes, there are tools emerging that are able to generate client libraries automatically for a variety of languages. For example, [OpenAPI Generator](https://openapi-generator.tech/)/[Swagger Codegen](https://openapi-generator.tech/docs/faq#what-is-the-difference-between-swagger-codegen-and-openapi-generator). Such tools know the API and know how to generate boilerplate HTTP client code around it. HTTP client code does not need to be interesting or unique. There are response conditions that may need to be handled in unique ways due to context, but that can happen outside of API client code.

Something similar is GCP's [Magic Modules](https://github.com/GoogleCloudPlatform/magic-modules). Magic Modules knows the GCP API and can automatically create support for Terraform, Ansible, and InSpec. Updating APIs and solving certain issues in a single place makes improvements for all of those tools.

### Shared Grafana Models Among Languages

It seems to me the same could be done for Grafana dashboard schemas. A centralized schema definition could be used to generate Grafana dashboard libraries for a variety of languages. What's left is for teams to do what else is important to them and write actual dashboards in the language of their choice.

This might eliminate the tug-of-war over who made the best dashboard generation tool. As well the speculation of which will eventually emerge as the standard.

Having a central, well modeled, well versioned schema library that translates the same in any language, seems to me to be decent compromise.

I don't have a PoC, just the preceding ramblings. I'll hopefully be able to follow up in another post with progress.
