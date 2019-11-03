//<?php
/**
 * Payment Robokassa
 *
 * Robokassa payments processing
 *
 * @category    plugin
 * @version     0.1.1
 * @author      mnoskov
 * @internal    @events OnRegisterPayments,OnBeforeOrderSending,OnManagerBeforeOrderRender
 * @internal    @properties &title=Название;text; &merchant_login=Идентификатор магазина;text; &pass1=Пароль 1;text; &pass2=Пароль 2;text; &debug=Отладка;list;Нет==0||Да==1;0 &testpass1=Отладочный пароль 1;text; &testpass2=Отладочный пароль 2;text; &vat_code=Ставка НДС;list;НДС не облагается==none||НДС 0%==vat0||НДС по формуле 10/110==vat110||НДС по формуле 20/120==vat120||НДС 10%==vat10||НДС 20%==vat20;none
 * @internal    @modx_category Commerce
 * @internal    @installset base
*/

if (!empty($modx->commerce)) {
    $isSelectedPayment = !empty($order['fields']['payment_method']) && $order['fields']['payment_method'] == 'robokassa';
    $lang = $modx->commerce->getUserLanguage('robokassa');

    switch ($modx->event->name) {
        case 'OnRegisterPayments': {
            $class = new \Commerce\Payments\RobokassaPayment($modx, $params);

            if (empty($params['title'])) {
                $params['title'] = $lang['robokassa.caption'];
            }

            $modx->commerce->registerPayment('robokassa', $params['title'], $class);
            break;
        }

        case 'OnBeforeOrderSending': {
            if ($isSelectedPayment) {
                $FL->setPlaceholder('extra', $FL->getPlaceholder('extra', '') . $modx->commerce->loadProcessor()->populateOrderPaymentLink());
            }

            break;
        }

        case 'OnManagerBeforeOrderRender': {
            if (isset($params['groups']['payment_delivery']) && $isSelectedPayment) {
                $params['groups']['payment_delivery']['fields']['payment_link'] = [
                    'title'   => $lang['robokassa.link_caption'],
                    'content' => function($data) use ($modx) {
                        return $modx->commerce->loadProcessor()->populateOrderPaymentLink('@CODE:<a href="[+link+]" target="_blank">[+link+]</a>');
                    },
                    'sort' => 50,
                ];
            }

            break;
        }
    }
}
