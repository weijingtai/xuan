《铁板神数》原子算法引擎 - 项目说明与开发指南 v1.0

章节一：项目愿景与核心思想

本项目的核心目标是将《铁板神数》中复杂、多变、且规则繁多的算法逻辑，从传统“硬编码”的开发模式中解放出来，构建一个灵活、可扩展、数据驱动的“原子算法引擎”。

我们旨在解决以下核心问题：

逻辑僵化: 硬编码的算法难以修改和扩展，每次微调都需要改动代码并重新编译发布。
知识孤岛: 算法逻辑深埋于代码中，只有最初编写它的开发者才完全理解，不利于团队协作和知识传承。
开发效率低下: 新增一种算法流派或计算方法，几乎等同于重写一个独立的模块。
通过本引擎，我们实现了：

算法即配置: 任何一种复杂的算法，最终都表现为一个人类可读的JSON配置文件。
逻辑可复用: 算法的每一个计算环节都被抽象为可复用的“原子操作”。
开发模式转变: 未来开发新算法，将主要由“配置JSON”驱动，而非“编写Dart代码”驱动，极大地提高了效率和灵活性。
章节二：核心概念解析 (团队通用语)

原子操作 (Atomic Operation)

定义: 系统中最小的功能单元，一个独立的、不可再分的计算逻辑（例如：“数学运算”、“数据映射”、“执行子流程”）。
物理位置: tiebanshenshu/lib/algorithm/operations/ 目录下的Dart文件中。
类比: 工具箱里的一件具体工具，如一把螺丝刀、一个扳手。
执行步骤 (Execution Step)

定义: 在一个具体的算法流程中，对某个“原子操作”的一次调用实例。它负责定义这个原子操作具体要“操作谁”（输入映射）以及“结果放哪里”（输出映射）。
物理位置: 在算法的JSON配置文件中，是steps数组里的一个对象。
类比: 菜谱里的一个步骤，例如：“第3步：用[盐]这个工具，作用于[切好的土豆丝]上，得到[腌制中的土豆丝]”。
算法配置 (Algorithm Configuration)

定义: 一个完整的JSON文件，它通过一个有序的“执行步骤”列表，定义了一种完整的算法。它是我们引擎可以理解和执行的“源代码”。
物理位置: tiebanshenshu/assets/algorithms/ 目录下。
类比: 一份完整的菜谱。
执行上下文 (Execution Context)

定义: 一次算法执行过程中的“临时记忆区”。它负责存储和管理所有的数据，包括初始输入、所有步骤产生的中间结果、以及最终的输出。
物理位置: 在内存中，由ExecutionEngine创建和管理。
类比: 厨师面前的工作台，上面放着所有食材、切好的半成品和最终的菜肴。
执行引擎 (Execution Engine)

定义: 整个系统的大脑和指挥官。它负责读取“算法配置”（菜谱），创建“执行上下文”（工作台），然后严格按照“执行步骤”的顺序，调用相应的“原子操作”（工具），完成整个计算流程。
物理位置: tiebanshenshu/lib/algorithm/execution_engine.dart。
类比: 厨师本人。
章节三：系统架构与工作流

本引擎采用经典的“解释器模式”进行设计。

架构图:

graph TD
    A[用户调用: 执行'算法A'] --> B(AlgorithmCompiler);
    B --> C{ConfigurationEngine};
    C --> D[读取 '算法A.json'];
    B --> E{ExecutionEngine};
    D --> E;
    B --> F[创建 ExecutionContext];
    F --> E;
    
    subgraph "循环执行每一个Step"
        E --> G{SyncExecutor};
        G --> H{AtomicOperationRegistry};
        H --> I[获取 '原子操作X' 的实例];
        G --> F;
        I -- 执行 --> G;
        G -- 更新数据 --> F;
    end
    
    E --> J[返回最终结果];
工作流详解 (QA与PM关注):

启动: 外部调用AlgorithmCompiler.executeAlgorithm，并传入要执行的算法ID和初始输入数据。
加载: ConfigurationEngine根据算法ID，从assets目录中找到并加载对应的JSON文件，解析成AlgorithmConfig对象。
初始化: AlgorithmCompiler创建一个ExecutionContext实例，并将初始输入数据存入其中。
执行: ExecutionEngine开始遍历AlgorithmConfig中的steps列表。
对于每一个步骤: a. SyncExecutor读取该步骤的inputs（输入映射）。 b. 它根据映射规则，从ExecutionContext中提取所需的数据（例如，从intermediate.step1_output中获取上一步的结果）。 c. 它根据步骤的operationId，从AtomicOperationRegistry中获取对应的“原子操作”实例。 d. 它调用该原子的execute方法，并将准备好的数据作为参数传入。 e. 原子执行其内部逻辑，并返回一个包含结果的Map。 f. SyncExecutor读取该步骤的outputs（输出映射），并将原子的返回结果，根据映射规则存回ExecutionContext中（例如，存为intermediate.step2_result）。
循环: ExecutionEngine继续执行下一个步骤，重复第5步，直到所有步骤完成。
产出: 整个流程结束后，ExecutionContext中的outputs区存储的数据，就是本次算法的最终结果，并将其返回给调用者。
章节四：开发者与使用者指南

A. 如何新增一个“原子操作”？(针对开发者)

这是扩展引擎能力的主要方式。请遵循以下Checklist：

选择或创建文件: 根据原子功能，在tiebanshenshu/lib/algorithm/operations/目录下选择一个合适的分类文件（如utility_operations.dart），或为新的领域创建一个新文件。
创建类: 创建一个新的Dart类，继承自AtomicOperation。
定义元数据: 在构造函数中，定义好id (全系统唯一), name, category, description等元数据。这是UI能够展示它的基础。
定义参数:
实现inputParameters getter，为每个输入参数创建一个ParameterDefinition。
实现outputParameters getter，为每个输出结果创建一个ParameterDefinition。
关键: ParameterDefinition中的name, description, type等信息，是未来UI实现“语义化交互”和“上下文帮助”的基础，请务必认真填写。
实现execute方法: 在此方法中编写该原子的核心业务逻辑。方法可以读取inputs，并必须返回一个包含所有在outputParameters中定义的输出键的Map。
注册原子: 在该文件底部的包装类（如 UtilityOperations）的getOperations()静态方法中，加入你的新原子实例。ProductionAtomicOperationRepository会自动发现并加载它。
编写单元测试: 在 tiebanshenshu/test/operations/目录下，为你的新原子创建一个测试文件，验证其逻辑的正确性。
B. 如何新增一个“算法”？(针对算法设计者/PM/QA)

这是使用引擎的主要方式。

创建JSON文件: 在tiebanshenshu/assets/algorithms/目录下，创建一个新的.json文件。
定义元数据: 填写顶层的name, description, version等信息。
定义全局配置 (globalConfig): 如果算法中包含多处需要用到的固定配置（如“天干地支对应卦象”的Map），建议放在globalConfig中，便于步骤中通过config.xxx引用。
编写执行步骤 (steps数组):
id: 步骤的唯一标识符，用于依赖关系和分支跳转。
operationId: 要调用的“原子操作”的ID。可以查阅operations目录下的代码来获取所有可用的ID。
inputs: 定义当前步骤所需的数据来源。
引用上下文: 值如果是"intermediate.step1.result"这样的字符串，引擎会自动从上下文中获取step1产生的名为result的输出。
使用字面量: 值也可以是直接量，如123, true, ["a", "b"]等。
使用模板: 在loop原子内部，可以使用{{currentItem}}或{{currentItem.field}}这样的模板语法。
outputs: 定义当前步骤的产出物要存放在上下文中的哪个位置。例如{"result": "my_super_result"}会将原子产出的result存为intermediate.my_super_result。
章节五：项目现状、待办与展望

已完成:

核心引擎框架（编译器、执行器、上下文、原子注册表）已全部实现。
核心流程控制原子（loop, run_sub_flow, conditional）已实现并经过增强。
数据模型层已全部使用json_serializable重构，稳定且健壮。
一个功能性的UI编辑器原型已完成。
已成功将太玄四柱、八卦滚法、皇极取数法等多个复杂算法从硬编码逻辑翻译为JSON配置，并为此定义了大量可复用的领域专用原子。
待办事项 (TODO):

实现原子逻辑: 我们定义的大部分领域专用原子（如generate_najia）的execute方法目前是空的。需要领域专家或原代码开发者来填充其具体实现。这是当前最高优先级的工作。
UI/UX优化: 根据我之前给出的建议，将UI从“列表编辑器”升级为“可视化画布（节点编辑器）”，以实现最终的、用户友好的产品形态。
翻译剩余算法: 将lib/service目录下剩余的约9个旧算法，全部翻译为新的JSON配置。
