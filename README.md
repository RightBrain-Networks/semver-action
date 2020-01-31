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

The exit code of semver. Returns 0 on new version.

See the [exit codes section on auto-semver README](https://github.com/RightBrain-Networks/auto-semver#usage).

##### `SEMVER_NEW_VERSION`

The version pulled from the `.bumpversion.cfg` file after being updated

##### `VERSION`

The version outputed by semver.

#### Example

In this example, auto-semver runs on master and creates a release on a new version:

```yaml
name: Version & Release

on:
  push:
    branches:
      - master

jobs:
  CheckVersion:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v1
    - name: Run Auto-Semver
      id: semver
      uses: RightBrain-Networks/semver-action@v1.0.0
      with:
        mode: set
    - name: Create Release
      uses: actions/create-release@v1
      if: steps['semver']['outputs']['RETURN_STATUS'] == '0'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
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

In this example, the version is updated from the `ref` to build a python package.

```yaml
name: Build Python Package
on:
  release:
    types:
    - created

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Set up Python 3.7
      uses: actions/setup-python@v1
      with:
        python-version: 3.7
    - name: Run Auto-Semver
      id: semver
      uses: RightBrain-Networks/semver-action@v1.0.0
      with:
        mode: set
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    - name: build
      run: |
        python setup.py sdist bdist_wheel
```
