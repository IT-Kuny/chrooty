#!/usr/bin/env bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "parse_args sets flags correctly" {
  run bash -c "source ../chrooty; parse_args --no-prompt --system --verbose"
  assert_success
  # Since parse_args uses verbose_log, we expect output when VERBOSE
  assert_output --partial "Interactive mode disabled"
}

@test "parse_args errors on conflicting flags" {
  run bash -c "source ../chrooty; parse_args --system --uefi"
  assert_failure
  assert_output --partial "Cannot specify both --system and --uefi"
}

@test "parse_args errors when no target with no-prompt" {
  run bash -c "source ../chrooty; parse_args --no-prompt"
  assert_failure
  assert_output --partial "--no-prompt requires either --system or --uefi"
}
