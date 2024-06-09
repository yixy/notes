
# spf13——cobra #

Cobra is both a library for creating powerful modern CLI applications as well as a program to generate applications and command files.


## 1. Command line syntax ##

Commands represent actions, Args are things and Flags are modifiers（修饰语） for those actions.

```
APPNAME COMMAND ARG --FLAG
```

flag的格式中，最后一种格式不能用于bool类型的flag，因为如果有文件名为0、false等的文件会有歧义)

```
--flag=x    //flags without a 'no option default value'
--flag    //flags with no option default values
--flag x  // non-boolean flags
```

## 2. How to use ##

项目结构：

```
  ▾ appName/
    ▾ cmd/
        add.go
        your.go
        commands.go
        here.go
      main.go
```

初始化cobra：

```
package main
import (
  "{pathToYourApp}/cmd"
)
func main() {
  cmd.Execute()
}
```

Execute should be run on the root for clarity, though it can be called on any command.

初始化app/cmd/root.go:

```
var rootCmd = &cobra.Command{
  Use:   "hugo",
  Short: "Hugo is a very fast static site generator",
  Long: `A Fast and Flexible Static Site Generator built with
                love by spf13 and friends in Go.
                Complete documentation is available at http://hugo.spf13.com`,
  Run: func(cmd *cobra.Command, args []string) {
    // Do Stuff Here
  },
}

func Execute() {
  if err := rootCmd.Execute(); err != nil {
    fmt.Println(err)
    os.Exit(1)
  }
}
```

create a additional command you would create  and populate it with the following:

cmd/version.go：

```
package cmd
import (
  "fmt"

  "github.com/spf13/cobra"
)
func init() {
  rootCmd.AddCommand(versionCmd)
}
var versionCmd = &cobra.Command{
  Use:   "version",
  Short: "Print the version number of Hugo",
  Long:  `All software has versions. This is Hugo's`,
  Run: func(cmd *cobra.Command, args []string) {
    fmt.Println("Hugo Static Site Generator v0.9 -- HEAD")
  },
}
```

* Required flags：

Flags are optional by default. If instead you wish your command to report an error when a flag has not been set, mark it as required:

```
rootCmd.Flags().StringVarP(&Region, "region", "r", "", "AWS region (required)")
rootCmd.MarkFlagRequired("region")
```

Validation of positional arguments can be specified using the Args field of Command.

* The following validators are built in:

```
NoArgs - the command will report an error if there are any positional args.
ArbitraryArgs - the command will accept any args.
OnlyValidArgs - the command will report an error if there are any positional args that are not in the ValidArgs field of Command.
MinimumNArgs(int) - the command will report an error if there are not at least N positional args.
MaximumNArgs(int) - the command will report an error if there are more than N positional args.
ExactArgs(int) - the command will report an error if there are not exactly N positional args.
ExactValidArgs(int) - the command will report an error if there are not exactly N positional args OR if there are any positional args that are not in the ValidArgs field of Command
RangeArgs(min, max) - the command will report an error if the number of args is not between the minimum and maximum number of expected args.
```

* An example of setting the custom validator:

```
var cmd = &cobra.Command{
  Short: "hello",
  Args: func(cmd *cobra.Command, args []string) error {
    if len(args) < 1 {
      return errors.New("requires a color argument")
    }
    if myapp.IsValidColor(args[0]) {
      return nil
    }
    return fmt.Errorf("invalid color specified: %s", args[0])
  },
  Run: func(cmd *cobra.Command, args []string) {
    fmt.Println("Hello, World!")
  },
}
```

## 3. Working with Flags ##

A flag can be 'persistent' meaning that this flag will be available to the command it's assigned to as well as every command under that command. For global flags, assign a flag as a persistent flag on the root.

```
//Persistent Flags
rootCmd.PersistentFlags().BoolVarP(&Verbose, "verbose", "v", false, "verbose output")
```

A flag can also be assigned locally which will only apply to that specific command.

```
//Local Flags
localCmd.Flags().StringVarP(&Source, "source", "s", "", "Source directory to read from")
```

By default Cobra only parses local flags on the target command, any local flags on parent commands are ignored. By enabling Command.TraverseChildren Cobra will parse local flags on each command before executing the target command.

```
command := cobra.Command{
  Use: "print [OPTIONS] [COMMANDS]",
  TraverseChildren: true,
}
```

You can also bind your flags with viper:

```
var author string
func init() {
  rootCmd.PersistentFlags().StringVar(&author, "author", "YOUR NAME", "Author name for copyright attribution")
  viper.BindPFlag("author", rootCmd.PersistentFlags().Lookup("author"))
}
```

## 4. help ##

Cobra automatically adds a help command 

You can provide your own Help command or your own template for the default command to use with following functions:

```
cmd.SetHelpCommand(cmd *Command)
cmd.SetHelpFunc(f func(*Command, []string))
cmd.SetHelpTemplate(s string)
```

The latter two will also apply to any children commands.

## 5. usage ##

When the user provides an invalid flag or invalid command, Cobra responds by showing the user the 'usage'.

the default help embeds the usage as part of its output.

You can provide your own usage function or template for Cobra to use. Like help, the function and template are overridable through public methods:

```
cmd.SetUsageFunc(f func(*Command) error)
cmd.SetUsageTemplate(s string)
```

## 6. Version Flag ##

Cobra adds a top-level '--version' flag if the Version field is set on the root command. Running an application with the '--version' flag will print the version to stdout using the version template. The template can be customized using the cmd.SetVersionTemplate(s string) function.

## 7. Cobra Generator ##

Cobra provides its own program that will create your application and add any commands you want. It's the easiest way to incorporate Cobra into your application.

> https://github.com/spf13/cobra/blob/master/cobra/README.md