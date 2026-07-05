#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-info(
    author: "Beautiful Name",
  ),
)


== Touying Get Config

#touying-get-config().info.author

#touying-get-config("info").author

#touying-get-config("info.author")

#touying-get-config("random.dict.value", default: "default value")

== With custom Config

//and once we randomly create a new config and try to retrieve it.
#show: touying-set-config.with((random: (dict: (value: 123))))

#touying-get-config("random.dict.value")

//but this does not work:
#touying-get-config("random.dict").value


