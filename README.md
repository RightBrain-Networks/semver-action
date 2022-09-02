![Release Version](https://img.shields.io/github/v/release/RightBrain-Networks/semver-action) ![Self Version & Release](https://github.com/RightBrain-Networks/semver-action/workflows/Self%20Version%20&%20Release/badge.svg)

# semver-action

Github Action for RBN Auto Semver by Branch tool

## Usage

Runs to either set or get the semantic version managed by auto-semver.

### Inputs

#### `mode`

Accepted values: `get`, `set`

Default: `set`

### `set` mode

#### Outputs

##### `RETURN_STATUS`

The exit code of Auto-Semver. Auto-Semver returns an exit code of 0 on new version. This resolves to an empty string in the 
action output.

See the [exit codes section on auto-semver README](https://github.com/RightBrain-Networks/auto-semver#usage).

##### `SEMVER_NEW_VERSION`

The version pulled from the `.bumpversion.cfg` file after being updated

##### `VERSION`

The version outputted by semver.

#### Example

In this example, auto-semver runs on master and creates a release on a new version. 

##### About Generating Releases With Workflows
It is recommended to use a Personal Access Token stored in repo secrets, if the release is intended to trigger another 
workflow or job, such as one to execute semver get mode on the new version number. 

```yaml
env:
        GITHUB_TOKEN: ${{ secrets.MY_PERSONAL_ACCESS_TOKEN }}
```
As per Github's documentation:
> When you use the repository's GITHUB_TOKEN to perform tasks on behalf of the GitHub Actions app, events triggered by 
> the GITHUB_TOKEN will not create a new workflow run. This prevents you from accidentally creating recursive workflow 
> runs.

https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

#### **To prevent a potential endless loop, ensure the job that generates the release cannot be triggered by that release**
```yaml
if: github.event_name != 'release' && github.event.action != 'created'
```

#### Full Example
```yaml
name: Version & Release

on:
  push:
    branches:
      - master

jobs:
  CheckVersion:
    runs-on: ubuntu-latest
    if: github.event_name != 'release' && github.event.action != 'created'
    outputs:
        RETURN_STATUS: steps['semver']['outputs']['RETURN_STATUS']
        VERSION: steps['semver']['outputs']['VERSION']
    steps:
    - name: Checkout
      uses: actions/checkout@v1
    - name: Set Up Git Config
      run: |
          git config user.name "GitHub Actions Bot"
          git config user.email "<>"
    - name: Run Auto-Semver
      id: semver
      uses: RightBrain-Networks/semver-action@1.0.0
      with:
        mode: set
    - name: Create Release
      uses: actions/create-release@v1
      if: steps['semver']['outputs']['RETURN_STATUS'] == ''
      env:
        GITHUB_TOKEN: ${{ secrets.MY_PERSONAL_ACCESS_TOKEN }}
      with:
        tag_name: ${{ steps.semver.outputs.SEMVER_NEW_VERSION }}
        release_name: ${{ steps.semver.outputs.SEMVER_NEW_VERSION }}
        body: Version ${{ steps.semver.outputs.SEMVER_NEW_VERSION }} released automatically by [RightBrain-Networks/auto-semver](https://github.com/RightBrain-Networks/auto-semver)
        draft: false
        prerelease: false
```

### `get` mode

This mode grabs the version from the `ref` and updates any files listed in `.bumpversion.cfg`

Therefore, to get the proper version the trigger should be a release or a push to tags. 

#### Outputs

##### `VERSION`

The semantic version found in the `ref`

#### Example

In this example, the version is updated from the `ref` to build a python package. It is set to only run when a release
is created.

```yaml
name: Build Python Package
on:
  release:
    types:
    - created

jobs:
  build:
    runs-on: ubuntu-latest
    if: github.event_name == 'release' && github.event.action == 'created'
    steps:
    - uses: actions/checkout@v1
    - name: Set up Python 3.7
      uses: actions/setup-python@v1
      with:
        python-version: 3.7
    - name: Set Up Git Config
      run: |
          git config user.name "GitHub Actions Bot"
          git config user.email "<>"
    - name: Run Auto-Semver
      id: semver
      uses: RightBrain-Networks/semver-action@1.0.0
      with:
        mode: get
```
