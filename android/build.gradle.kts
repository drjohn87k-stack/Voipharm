// 1. Force external plugins to resolve their own dependencies via Central/Google instead of JCenter
buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

// Your existing root build.gradle contents follow below...
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
