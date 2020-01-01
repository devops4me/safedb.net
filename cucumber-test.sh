#!/bin/bash

# ++ +++ ++++++ # +++++ +++++++ # +++ +++++++++ # +++++++ # ++++ +++++ ++ #
# ++ --- ------ # ----- ------- # --- --------- # ------- # ---- ----- ++ #
# ++                                                                   ++ #
# ++  Prepare for the cucumber orchestrated tests that are part of the ++ #
# ++  build for the safedb personal database. This script exports the  ++ #
# ++  protective safe token and then executes cucumber feature files.  ++ #
# ++                                                                   ++ #
# ++ --- ------ # ----- ------- # --- --------- # ------- # ---- ----- ++ #
# ++ +++ ++++++ # +++++ +++++++ # +++ +++++++++ # +++++++ # ++++ +++++ ++ #

# Exit this script when any command fails
set -e

echo "" ; echo "" ;
echo "### ################################## ###"
echo "### Ruby Execution Environment Details ###"
echo "### ################################## ###"
echo ""

echo "Current directory is $(pwd)"
echo "Current username is $(whoami)"
echo "" ; ls -lh
safe version

echo ""
echo "### ################################ ###"
echo "### Exporting safe shell (tty) token ###"
echo "### ################################ ###"
echo ""

export SAFE_TTY_TOKEN=$(safe token)
printenv

echo "" ; echo "" ;
echo "### ###################################### ###"
echo "### Now executing the cucumber/aruba tests ###"
echo "### ###################################### ###"
echo ""

cucumber lib
echo ""

exit 0
