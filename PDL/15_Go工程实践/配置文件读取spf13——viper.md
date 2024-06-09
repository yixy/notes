
# spf13——viper #

Viper is a complete configuration solution for Go applications. Go configuration with fangs.

https://github.com/spf13/viper

Viper configuration keys are case insensitive.

## 1. 支持功能及优先级 ##

Viper uses the following precedence order. Each item takes precedence over the item below it:（优先级从上到下，上层配置会覆盖下层）

* explicit call to Set：setting explicit values(直接赋值，这里的set是动词)
* flag: reading from command line flags
* env: reading from environment variables
* config: reading from JSON, TOML, YAML, HCL, envfile and properties config files (support live watching and re-reading of config files); or use io.Reader
* remote K/V store：reading from remote config systems (etcd or Consul), and watching changes
* set default：viper支持设置默认值

## 2. set default ##

viper支持设置默认值

```
//default
viper.SetDefault("ContentDir", "content")
```

## 3. remote K/V store ##

To enable remote support in Viper, do a blank import of the viper/remote package:

```
import _ "github.com/spf13/viper/remote"
```

## 4. config ##

support config file.

```
//read config
viper.SetConfigName("config") // name of config file (without extension)
viper.AddConfigPath("/etc/appname/")   // path to look for the config file in
err := viper.ReadInConfig() // Find and read the config file
if err != nil { // Handle errors reading the config file
    panic(fmt.Errorf("Fatal error config file: %s \n", err))
}

//write config
viper.WriteConfig()
viper.SafeWriteConfig()
viper.WriteConfigAs("/path/to/my/.config")
viper.SafeWriteConfigAs("/path/to/my/.config")

//Watching and re-reading config files
viper.WatchConfig()
viper.OnConfigChange(func(e fsnotify.Event) {
    fmt.Println("Config file changed:", e.Name)
})
```

you are not bound to files.

```
//Reading Config from io.Reader
viper.SetConfigType("yaml") // or viper.SetConfigType("YAML")
// any approach to require this configuration into your program.
var yamlExample = []byte(`
Hacker: true
name: steve
hobbies:
- skateboarding
- snowboarding
- go
clothing:
  jacket: leather
  trousers: denim
age: 35
eyes : brown
beard: true
`)
viper.ReadConfig(bytes.NewBuffer(yamlExample))
viper.Get("name") // this would be "steve"
```

## 5. env环境变量 ##

When working with ENV variables, it’s important to recognize that Viper treats ENV variables as case sensitive.

Viper has full support for environment variables. There are five methods that exist to aid working with ENV:

* SetEnvPrefix(string): （为确保ENV变量是唯一的）tell Viper to use a prefix while reading from the environment variables. Both BindEnv and AutomaticEnv will use this prefix.

* AutomaticEnv(): Viper will check for an environment variable any time a viper.Get request is made.It will check for a environment variable with a name matching the key uppercased and prefixed with the EnvPrefix if set.

One important thing to recognize when working with ENV variables is that the value will be read each time it is accessed. Viper does not fix the value when the BindEnv is called.

* BindEnv(string...) : The first parameter is the key name, the second is the name of the environment variable.If the ENV variable name is not provided, then Viper will automatically assume that the ENV variable matches the following format: prefix + "_" + the key name in ALL CAPS.When you explicitly provide the ENV variable name (the second parameter), it does not automatically add the prefix.

* SetEnvKeyReplacer(string...) *strings.Replacer：SetEnvKeyReplacer allows you to use a strings.Replacer object to rewrite Env keys to an extent. This is useful if you want to use - or something in your Get() calls, but want your environmental variables to use _ delimiters. An example of using it can be found in viper_test.go.

* AllowEmptyEnv(bool)：By default empty environment variables are considered unset and will fall back to the next configuration source. To treat empty environment variables as set, use the AllowEmptyEnv method.

## 6. flag ##

Viper supports Pflags as used in the Cobra library.

## 7. setting explicit values ##

```
viper.Set("Verbose", true)
viper.Set("LogFile", LogFile)
```