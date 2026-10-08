# 贡献指南

> 本项目当前处于**固件普查阶段**。最重要的贡献不是代码，是一份准确的固件样本。

---

## 一、先做什么（按优先级）

| 优先级 | 事情 | 门槛 |
|---|---|---|
| 1 | 填写 `docs/FIRMWARE-CENSUS.md` 样本表 | 无，有车就行 |
| 2 | 按 `docs/TESTING.md` 跑一遍并提交结果 | 无 |
| 3 | 更新 `docs/COMPATIBILITY.md` 兼容矩阵 | 无 |
| 4 | 修文档滞后、补齐模板 | 会 Git |
| 5 | 通用层代码修复（老 API 兼容、USB 链路、后台保活） | 会 Android/Kotlin |
| 6 | 吉利专属适配（原厂蓝牙通路、方向盘按键、HUD） | 需要固件逆向能力 |

---

## 二、不会写代码怎么参与

你提供的价值不比代码低——这个项目的瓶颈是**数据**，不是代码。

1. 拍一张「关于本机」的完整照片，填进 `FIRMWARE-CENSUS.md`
2. 按 `TESTING.md` 逐项打勾，失败也要提交（失败数据同样关键，能定位失败阶段）
3. 复现问题后保存诊断报告，脱敏后附上

**提交失败结果时请务必写清失败发生在哪个阶段**：装不上 / 启动闪退 / 搜不到手机 / 握手失败 / 出画面但没声音 / 触控无响应。定位到阶段才能推进。

---

## 三、开发者须知

### 3.1 上游关系

三个上游均为 GPL-3.0，本项目同样 GPL-3.0。改动应尽量**回流上游**，不要制造长期分叉：

| 改动类型 | 去向 |
|---|---|
| 老 API 兼容、USB 协议、后台保活、崩溃修复 | 提 PR 给 `programmerguohuajing/DiPlay-Legacy-Android` |
| 比亚迪无关的低版本通用问题 | 同上 |
| 吉利 E01 专属固件适配 | 留在本仓库 |
| 吉利 4.3 车机（非 5.1） | 转给 `xikai6282/DiPlay-Geely-Android43` |

### 3.2 构建环境

沿用上游要求：JDK 25、Android SDK 37、NDK 25.2.9519653（r25c 是能输出 API19 native target 的最后一个工具链）。

```bash
./gradlew :shared:testDebugUnitTest :common:testDebugUnitTest :mobile:lintDebug :mobile:assembleDebug
```

### 3.3 红线（违反会被拒绝合并）

- **认证身份资产不得进入 Git**：`offline-mfi/identity.pk8`、`offline-mfi/certificate.p7b`
- **签名私钥与 keystore 不得进入 Git**，也不要贴到 issue 里
- **不得分发可用的已签名 APK**
- 提交日志/报告前完成脱敏

### 3.4 源码构建的包跑不了 CarPlay

上游 `docs/BUILD.md` 明确：源码构建**故意不含配件身份**，source-only APK 无法完成 CarPlay 认证。要得到可用包，需显式提供外部资产目录：

```
DIPLAY_AUTH_ASSETS_DIR/
  offline-mfi/identity.pk8
  offline-mfi/certificate.p7b
```

因此验证你的代码改动，要么用官方渠道 APK + `scripts/repack.sh` 本地组装，要么自行准备资产。**不要因为"编译出来连不上"就误判是自己代码的问题。**

### 3.5 签名

不同签名密钥**不能覆盖**已安装的项目签名版本。本地签名包需先卸载旧包——务必先导出诊断报告。

---

## 四、提交规范

- Issue 标题前缀：`[Compat]` 兼容数据 / `[Bug]` 缺陷 / `[Doc]` 文档 / `[RFE]` 功能请求
- PR 请说明：改动动机、影响到的固件分支、在哪些车机上验证过（未验证就写明未验证）
- **不要把未验证的结果写成已验证**

---

## 五、行为准则

- 不嘲笑新手提问，同一个问题被问十次说明文档没写好
- 不承诺时间表，这是业余时间的社区项目
- 涉及他人车辆的操作建议，必须附带风险提示
