node {
    def ARTIFACTS_PATH = 'targets/jonchki/repository/org/muhkuh/tools/muhkuh_base_cli/*/'

    docker.image("mbs_ubuntu_2004_x86_64").inside('-u root') {
        /* Clean before the build. */
        sh 'rm -rf .[^.] .??* *'

        checkout([$class: 'GitSCM',
            branches: [[name: '*/master']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [
                [$class: 'SubmoduleOption',
                    disableSubmodules: false,
                    recursiveSubmodules: true,
                    reference: '',
                    trackingSubmodules: false
                ]
            ],
            submoduleCfg: [],
            userRemoteConfigs: [[url: 'http://scm.netx01.hilscher.local/git/com.hilscher.muhkuh/board_tests/Wago_WiSli_Vorverguss']]
        ])

        /* Build the project. */
        sh "python3 mbs/mbs"

        /* Archive all artifacts. */
        archiveArtifacts artifacts: "${ARTIFACTS_PATH}/*.pom,${ARTIFACTS_PATH}/*.xml,${ARTIFACTS_PATH}/*.zip,${ARTIFACTS_PATH}/*.hash"

        /* Clean up after the build. */
        sh 'rm -rf .[^.] .??* *'
    }
}
