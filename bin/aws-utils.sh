# aws_mfa()
# ------------------------
# Generates a session token which will be used for all AWS command line
# operations.
#
# Although invoking AWS commands using a role which requires MFA
# results in an interactive prompt if needed — invoking the same operations from
# within 3rd party utility scripts/functions often don't make affordances for
# the interactive MFA prompts and instead become blocked.
#
# Warning!: This currently assumes working only in a single AWS account at a
# time and should be refactored to support multiple profiles.
#
#     $ aws_mfa ACCOUNT_ID ROLE TOKEN_CODE
#
aws_mfa() {
    if [[ -z "${1}" ]] || [[ -z "${2}" ]] || [[ -z "${3}" ]]; then
        echo "Usage: aws_mfa <account> <role> <token-code>" 1>&2
        return 1
    fi

    rm ~/.aws/credentials

    aws sts get-session-token \
    --serial-number "arn:aws:iam::${1}:mfa/${2}" \
    --token-code "${3}" \
    --duration-seconds 86400 \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text | awk '{ print "[default]\naws_access_key_id = "$1"\naws_secret_access_key = "$2"\naws_session_token = "$3"\n" }' \
    > ~/.aws/credentials
}


# tail-named-function()
# ------------------------
# Begins tailing the logs of a given AWS lambda function from CloudWatch.
#
#     $ tail-named-function STACK_NAME FUNTION_NAME
#
tail-named-function() {
    if [[ -z "${1}" ]]; then
        echo "Usage: tail-named-function STACK_NAME FUNTION_NAME" 1>&2
        return 1
    fi
    if [[ -z "${2}" ]]; then
        echo "Usage: tail-named-function STACK_NAME FUNTION_NAME" 1>&2
        return 1
    fi
    STACK_NAME=$1
    FUNCTION_NAME=$2

    command -v cw >/dev/null 2>&1 || {
        echo "cw is required. Please install from https://github.com/lucagrulla/cw" 1>&2
        return 1
    }

    func_name=$(aws cloudformation describe-stacks \
        --stack-name "${STACK_NAME}" \
        --query "Stacks[0].Outputs[?OutputKey==\`${FUNCTION_NAME}\`].OutputValue" \
        --output text)

    echo "cw tail -f /aws/lambda/${func_name}"
    cw tail -f "/aws/lambda/${func_name}"
}


################################################################################
# CloudFormation
################################################################################

# FUNCTIONS
# ---------
# ls-stacks()
#
# DESCRIPTION
# -----------
# This section defines functions which are useful when working with
# CloudFormation.
#
alias ls-stacks="aws cloudformation list-stacks \
    --stack-status-filter \
        CREATE_IN_PROGRESS \
        CREATE_COMPLETE \
        ROLLBACK_IN_PROGRESS \
        ROLLBACK_FAILED \
        ROLLBACK_COMPLETE \
        DELETE_IN_PROGRESS \
        DELETE_FAILED \
        UPDATE_IN_PROGRESS \
        UPDATE_COMPLETE_CLEANUP_IN_PROGRESS \
        UPDATE_COMPLETE \
        UPDATE_ROLLBACK_IN_PROGRESS \
        UPDATE_ROLLBACK_FAILED \
        UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS \
        UPDATE_ROLLBACK_COMPLETE \
        REVIEW_IN_PROGRESS \
    --query 'StackSummaries[*].[StackName,StackStatus]' \
    --output table"
