package com.roknmuslim.roknmuslimapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = buildRemoteViews(context, appWidgetManager, appWidgetId, widgetData)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        val widgetData = context.getSharedPreferences(
            "HomeWidgetPreferences",
            Context.MODE_PRIVATE
        )
        val views = buildRemoteViews(context, appWidgetManager, appWidgetId, widgetData)
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun buildRemoteViews(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        widgetData: android.content.SharedPreferences
    ): RemoteViews {
        val minWidth = appWidgetManager.getAppWidgetOptions(appWidgetId)
            .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val layout = resolveLayout(minWidth)
        val views = RemoteViews(context.packageName, layout)

        val prayerName = widgetData.getString("widget_prayer_name", "الصلاة القادمة")
        val prayerTime = widgetData.getString("widget_prayer_time", "--:--")
        val subtitle = widgetData.getString("widget_prayer_subtitle", "افتح التطبيق لتحديد الموقع")

        views.setTextViewText(R.id.widget_prayer_name, prayerName)
        views.setTextViewText(R.id.widget_prayer_time, prayerTime)
        views.setTextViewText(R.id.widget_prayer_subtitle, subtitle)

        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java
        )

        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        views.setOnClickPendingIntent(R.id.widget_action_primary, pendingIntent)
        if (layout == R.layout.prayer_widget_medium) {
            views.setOnClickPendingIntent(R.id.widget_action_secondary, pendingIntent)
        }

        return views
    }

    private fun resolveLayout(minWidth: Int): Int {
        return if (minWidth >= 240) {
            R.layout.prayer_widget_medium
        } else {
            R.layout.prayer_widget_small
        }
    }
}
