allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Redirect only the main app's build directory to the project root's build folder
// This satisfies Flutter's expectation while avoiding drive conflicts for plugins
project(":app") {
    layout.buildDirectory.value(rootProject.layout.projectDirectory.dir("../build/app"))
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
