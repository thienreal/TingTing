import { MigrationInterface, QueryRunner } from "typeorm";

export class InitTables1788191550220 implements MigrationInterface {
  name = "InitTables1788191550220";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "public"."user_vouchers_status_enum" AS ENUM('ACTIVE', 'USED', 'EXPIRED')`,
    );
    await queryRunner.query(
      `CREATE TABLE "user_vouchers" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "voucher_id" uuid NOT NULL, "status" "public"."user_vouchers_status_enum" NOT NULL DEFAULT 'ACTIVE', "redeemed_at" TIMESTAMP, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_66534a148ba312dd88e48ee6072" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "users" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "phone_number" character varying(20) NOT NULL, "full_name" character varying(100), "total_points" integer NOT NULL DEFAULT '0', "membership_tier" character varying(50) NOT NULL DEFAULT 'STANDARD', "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_17d1817f241f10a3dbafb169fd2" UNIQUE ("phone_number"), CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."transactions_type_enum" AS ENUM('EARN', 'REDEEM')`,
    );
    await queryRunner.query(
      `CREATE TABLE "transactions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "merchant_id" uuid NOT NULL, "type" "public"."transactions_type_enum" NOT NULL, "points_delta" integer NOT NULL, "bill_amount" numeric(12,2), "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_a219afd8dd77ed80f5a862f1db9" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "merchants" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying(150) NOT NULL, "email" character varying(100) NOT NULL, "password" character varying(255) NOT NULL, "category" character varying(100), "qr_static_code" character varying(255), "is_active" boolean NOT NULL DEFAULT true, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_7682193bcf281285d0a459c4b1e" UNIQUE ("email"), CONSTRAINT "PK_4fd312ef25f8e05ad47bfe7ed25" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "vouchers" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "merchant_id" uuid NOT NULL, "title" character varying(255) NOT NULL, "description" text, "points_cost" integer NOT NULL, "total_quantity" integer NOT NULL, "remaining_quantity" integer NOT NULL, "expired_at" TIMESTAMP NOT NULL, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_ed1b7dd909a696560763acdbc04" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_vouchers" ADD CONSTRAINT "FK_907ebb0f49f4650c8d68094183e" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_vouchers" ADD CONSTRAINT "FK_d9647d12bc95a815a68ae9b933c" FOREIGN KEY ("voucher_id") REFERENCES "vouchers"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "transactions" ADD CONSTRAINT "FK_e9acc6efa76de013e8c1553ed2b" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "transactions" ADD CONSTRAINT "FK_e80829a78860eadca0d60c8e21f" FOREIGN KEY ("merchant_id") REFERENCES "merchants"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "vouchers" ADD CONSTRAINT "FK_49fa70c04f6c7dfa458b7b29b19" FOREIGN KEY ("merchant_id") REFERENCES "merchants"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "vouchers" DROP CONSTRAINT "FK_49fa70c04f6c7dfa458b7b29b19"`,
    );
    await queryRunner.query(
      `ALTER TABLE "transactions" DROP CONSTRAINT "FK_e80829a78860eadca0d60c8e21f"`,
    );
    await queryRunner.query(
      `ALTER TABLE "transactions" DROP CONSTRAINT "FK_e9acc6efa76de013e8c1553ed2b"`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_vouchers" DROP CONSTRAINT "FK_d9647d12bc95a815a68ae9b933c"`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_vouchers" DROP CONSTRAINT "FK_907ebb0f49f4650c8d68094183e"`,
    );
    await queryRunner.query(`DROP TABLE "vouchers"`);
    await queryRunner.query(`DROP TABLE "merchants"`);
    await queryRunner.query(`DROP TABLE "transactions"`);
    await queryRunner.query(`DROP TYPE "public"."transactions_type_enum"`);
    await queryRunner.query(`DROP TABLE "users"`);
    await queryRunner.query(`DROP TABLE "user_vouchers"`);
    await queryRunner.query(`DROP TYPE "public"."user_vouchers_status_enum"`);
  }
}
