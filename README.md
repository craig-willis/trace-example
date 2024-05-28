# TRACE System (TRS) Example

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11367237.svg)](https://doi.org/10.5281/zenodo.11367237)


This repository contains a simple example of a TRACE System (TRS) that implements a manual workflow that includes the following steps:

* Authors submit information necessary to run their computational workflow.
* The TRS executes the workflow without author intervention, capturing the state of computational artifacts before and after execution (using the [`tro-utils`](https://github.com/transparency-certified/tro-utils) tool).
* The TRS excludes any files that cannot be redistributed due to privacy or intellectual property constraints, but retains metadata about them including file names and digests of their content (SHA-256).
* The TRO creates a Transparent Research Object (TRO) containing a record of the execution of the workflow within the system and digitally signs it..

## TRS Capabilities

Documented in [`trs.jsonld`](trs.jsonld):

| Capability    | Description |
| -------- | ------- |
| Prevents author intervention  | Authors are not involved in and cannot interfere with workflow execution. |
| Prevents network access | TRS may disable network access during execution.  |
| Excludes inputs         | TRS may exclude non-redistributable inputs from the resulting TRO. Excluded inputs are not retained by the TRS.|
| Excludes outputs        | TRS may exclude non-redistributable outputs from the resulting TRO. Excluded outputs are not retained by the TRS.|


## Scenario: Plotting the S&P500 

Consider the following scenario:

> A researcher is preparing to submit a manuscript to a journal with strict transparency and reproducibility requirements. Their manuscript includes a plot of the [S&P500](https://fred.stlouisfed.org/series/SP500) obtained using the [Federal Reserve Economic Data (FRED) API](https://fred.stlouisfed.org/docs/api/fred/). The FRED API terms of use prevent the author from sharing their private API key. The data underlying their plot is protected by copyright and S&P Down Jones, LLC, prohibits redistribution without permission. 

How can the author comply with journal transparency requirements without violating terms of use or copyright? 

To adhere to the journal's policy, the researcher submits their analysis to a TRS that provides a transparent record of their results while excluding protected information.

## Running the Example

Prerequisites:
* Linux-based OS
* GPG 
* Git
* [tro-utils](https://github.com/transparency-certified/tro-utils)


GPG and Git are usually installed in most Linux distributions. 


### Install `tro-utils`

Install [tro-utils](https://github.com/transparency-certified/tro-utils) from Github:

```
pip install git+https://github.com/transparency-certified/tro-utils
```

### Generate a GPG key for the system

The GPG key that will be used to sign TROs. To generate a GPG key for the TRS:

```
gpg --full-generate-key
```

You will be prompted to select the key type, key size, experation, as well as the name, email address, and passphrase for your key.

### Obtain a FRED API key

Running the example requires that you [obtain an API key from FRED](https://fred.stlouisfed.org/docs/api/api_key.html).

### Define Environment Variables

Export the following environment variables:
```
export GPG_FINGERPRINT=
export GPG_PASSPHRASE=
export FRED_APIKEY=
```

### Actually run the example

Run the example workflow
```
./run_example.sh
```

## Generated Artifacts

The `tro` directory contains the results of executing the example workflow:
* `trace-fred.jsonld`:  TRO declaration
* `trace-fred.sig`: TRO signature
* `trace-fred.tsr`: Timestamp signature
* `trace-fred.zip`: Archive of redistributable artifacts
* `trace-fred.md`: Sample TRO report (Markdown)
