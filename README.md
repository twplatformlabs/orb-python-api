<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/twplatformlabs/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/twplatformlabs/static/master/dps_lab_title.png" width=350/>
	</p>
  <h3>orb-python-api</h3>
  <h5>a workflow orb for test and build of fastAPI python services</h5>
  <a href="https://app.circleci.com/pipelines/github/twplatformlabs/orb-python-api"><img src="https://circleci.com/gh/twplatformlabs/orb-python-api.svg?style=shield"></a> <a href="https://badges.circleci.com/orbs/twdps/python-api.svg"><img src="https://badges.circleci.com/orbs/twdps/python-api.svg"></a> <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
</div>
<br />

See [orb registry](https://circleci.com/developer/orbs/orb/twplatformlabs/python-api) for detailed usage examples

Features include:

- Uses machine based executor for build
- Can provide custom job steps; before-build, after-build, after-push
- static analysis based on: pylint, pytest, hadolint
- supports codeclimate test reporting
