import { LevelUpAPI } from '../api/client'
import { Task, UserStats, Stat } from '../types'

@Entry
@Component
struct Index {
  @State tasks: Task[] = []
  @State stats: Stat[] = []
  @State userStats: UserStats | null = null
  @State loading: boolean = true

  private api: LevelUpAPI = new LevelUpAPI('http://localhost:3000/api', () => null)

  aboutToAppear() {
    this.loadData()
  }

  async loadData() {
    try {
      const [tasksRes, statsRes] = await Promise.all([
        this.api.getTasks(),
        this.api.getStats(),
      ])

      if (tasksRes.success) {
        this.tasks = tasksRes.data || []
      }

      if (statsRes.success) {
        this.stats = statsRes.data?.stats || []
        this.userStats = statsRes.data?.userStats || null
      }
    } catch (error) {
      console.error('Failed to load data:', error)
    } finally {
      this.loading = false
    }
  }

  @Builder
  StatBar(stat: Stat) {
    Column() {
      Row() {
        Text(stat.icon).fontSize(16)
        Text(stat.name).fontColor('#fff').layoutWeight(1)
        Text(stat.value.toString()).fontColor('#00d4ff').fontWeight(FontWeight.Bold)
      }.width('100%')

      Stack() {
        Row().width('100%').height(8).backgroundColor('#1e3a5f').borderRadius(4)
        Row()
          .width(`${(stat.value / stat.maxValue) * 100}%`)
          .height(8)
          .backgroundColor(stat.color)
          .borderRadius(4)
      }.width('100%').align(Alignment.Start)
    }.margin({ bottom: 12 })
  }

  @Builder
  TaskCard(task: Task) {
    Column() {
      Row() {
        Text(task.title)
          .fontColor('#fff')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text(task.type.toUpperCase())
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getTaskTypeColor(task.type))
          .fontColor('#000')
          .borderRadius(4)
      }.width('100%').margin({ bottom: 8 })

      if (task.description) {
        Text(task.description).fontColor('#888').margin({ bottom: 8 })
      }

      Row() {
        Text(`+${task.xp} XP`).fontColor('#00d4ff').fontWeight(FontWeight.Bold)
        Text(task.difficulty).fontColor('#888')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#0f2642')
    .borderRadius(12)
    .border({ width: 1, color: '#1e3a5f' })
    .margin({ bottom: 12 })
    .opacity(task.completed ? 0.6 : 1)
  }

  getTaskTypeColor(type: string): string {
    switch (type) {
      case 'main': return '#ff6b6b'
      case 'daily': return '#4ecdc4'
      case 'side': return '#ffe66d'
      default: return '#888'
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('LevelUp').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#00d4ff')
        if (this.userStats) {
          Text(`Lv.${this.userStats.level}`)
            .fontColor('#000')
            .fontWeight(FontWeight.Bold)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#00d4ff')
            .borderRadius(16)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#0f2642')
      .border({ width: { bottom: 1 }, color: '#1e3a5f' })
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.loading) {
        Text('加载中...').fontColor('#fff').fontSize(16).margin({ top: 100 })
      } else {
        Scroll() {
          Column() {
            // Stats Section
            Text('属性').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#fff').margin({ bottom: 12 })
            Column() {
              ForEach(this.stats, (stat: Stat) => {
                this.StatBar(stat)
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#0f2642')
            .borderRadius(12)
            .border({ width: 1, color: '#1e3a5f' })
            .margin({ bottom: 24 })

            // XP Progress
            if (this.userStats) {
              Column() {
                Row() {
                  Text(`XP: ${this.userStats.currentXP} / ${this.userStats.maxXP}`).fontColor('#fff')
                  Text(`${Math.round((this.userStats.currentXP / this.userStats.maxXP) * 100)}%`).fontColor('#00d4ff')
                }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 8 })

                Stack() {
                  Row().width('100%').height(12).backgroundColor('#1e3a5f').borderRadius(6)
                  Row()
                    .width(`${(this.userStats.currentXP / this.userStats.maxXP) * 100}%`)
                    .height(12)
                    .backgroundColor('#00d4ff')
                    .borderRadius(6)
                }.width('100%').align(Alignment.Start)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#0f2642')
              .borderRadius(12)
              .border({ width: 1, color: '#1e3a5f' })
              .margin({ bottom: 24 })
            }

            // Tasks Section
            Text('任务').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#fff').margin({ bottom: 12 })
            ForEach(this.tasks, (task: Task) => {
              this.TaskCard(task)
            })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0a1628')
  }
}
